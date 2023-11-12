import pathlib
import plistlib
import typing

import pydantic
import pydantic.alias_generators
import pydantic.functional_validators


def validate_umask(value: int) -> int:
    stringified_value = str(value)
    if len(stringified_value) > 4:
        raise ValueError("umask must shorter than 4 digits")

    for digit_char in stringified_value:
        if not (0 <= int(digit_char) <= 7):
            raise ValueError("umask must be a number between 0 and 7")

    return value


NullableUmaskField = typing.Annotated[int | None, pydantic.functional_validators.BeforeValidator(validate_umask)]


class ServiceModel(pydantic.BaseModel):
    model_config = pydantic.ConfigDict(
        alias_generator=pydantic.alias_generators.to_pascal,
        populate_by_name=True,
    )


class ServiceKeepAlive(ServiceModel):
    successful_exit: bool = True
    path_state: dict[str, dict[str, str]] | None = None  # avoid using this
    other_job_eanbled: dict[str, bool] | None = None  # avoid using this
    crashed: bool | None = None


class ServiceStartCalendarInterval(ServiceModel):
    minute: typing.Annotated[int | None, pydantic.Field(ge=0, le=59)] = None
    hour: typing.Annotated[int | None, pydantic.Field(ge=0, le=23)] = None
    day: typing.Annotated[int | None, pydantic.Field(ge=1, le=31)] = None
    weekday: typing.Annotated[int | None, pydantic.Field(ge=0, le=6)] = None
    month: typing.Annotated[int | None, pydantic.Field(ge=1, le=12)] = None


class ServiceResourceLimits(ServiceModel):
    core: pydantic.ByteSize | None = None
    cpu: pydantic.PositiveInt | None = None
    data: pydantic.ByteSize | None = None
    file_size: pydantic.ByteSize | None = None
    memory_lock: pydantic.ByteSize | None = None
    number_of_files: pydantic.PositiveInt | None = None
    number_of_processes: pydantic.PositiveInt | None = None
    resident_set_size: pydantic.ByteSize | None = None
    stack: pydantic.ByteSize | None = None


class ServiceMachServices(ServiceModel):
    reset_at_close: bool = False
    hide_until_check_in: bool | None = None


class ServiceSockets(ServiceModel):
    sock_type: typing.Literal["stream", "dgram", "seqpacket"] = "stream"
    sock_passive: bool = True
    sock_node_name: str | None = None
    sock_service_name: str | None = None
    sock_family: typing.Literal["IPv4", "IPv6", "IPv4v6"] | None = None
    sock_protocol: typing.Literal["TCP", "UDP"] | None = None
    sock_path_name: pydantic.FilePath | None = None
    secure_socket_with_key: pydantic.FilePath | None = None
    sock_path_owner: pydantic.PositiveInt | None = None
    sock_path_group: pydantic.PositiveInt | None = None
    sock_path_mode: NullableUmaskField = None
    bonjour: bool | str | list[str] | None = None
    multicast_group: str | None = None

    @pydantic.model_validator(mode="after")
    def validate(self) -> typing.Self:
        if self.multicast_group and not self.sock_family:
            raise ValueError("sock_family must be set when multicast_group is set")

        return self


class Service(ServiceModel):
    label: str | None = None
    disabled: bool = False

    program: pydantic.FilePath
    program_arguments: list[str] | None = None
    environment_variables: dict[str, str] | None = None

    enable_globbing: bool | None = None
    enable_transactions: bool | None = None
    enable_pressured_exit: bool | None = None

    run_at_load: bool | None = None  # avoid using this
    keep_alive: ServiceKeepAlive | bool | None = None
    launch_only_once: bool | None = None
    start_on_mount: bool | None = None

    exit_time_out: pydantic.PositiveInt | None = None
    throttle_interval: pydantic.PositiveInt | None = None
    start_interval: pydantic.PositiveInt | None = None
    start_calendar_interval: list[dict[str, int]] | None = None

    user_name: str | None = None
    group_name: str | None = None
    init_groups: bool | None = None
    umask: NullableUmaskField = None
    root_directory: pydantic.DirectoryPath | None = None  # avoid using this

    working_directory: pydantic.DirectoryPath | None = None
    queue_directories: list[pydantic.DirectoryPath] | None = None
    watch_paths: list[pydantic.DirectoryPath | pydantic.FilePath | pydantic.NewPath] | None = None  # avoid using this

    standard_in_path: pydantic.FilePath | None = None
    standard_out_path: pydantic.FilePath | pydantic.NewPath | None = None
    standard_error_path: pydantic.FilePath | pydantic.NewPath | None = None

    # limit_load_to_session_type: list[dict] | None = None  # TODO: implement this
    # limit_load_to_hardware: list[dict] | None = None  # TODO: implement this
    soft_resource_limits: ServiceResourceLimits | None = None
    hard_resource_limits: ServiceResourceLimits | None = None
    low_priority_io: bool | None = None
    low_priority_background_io: bool | None = None

    debug: bool | None = None
    wait_for_debugger: bool | None = None
    nice: typing.Annotated[int | None, pydantic.Field(ge=-20, le=20)] = None
    process_type: typing.Literal["Background", "Standard", "Adapathlibive", "Foreground"] | None = None
    abandon_process_group: bool | None = None
    materialize_dataless_files: bool | None = None
    mach_services: ServiceMachServices | None = None
    sockets: ServiceSockets | dict[str, list[ServiceSockets]] | None = None
    # launch_events: dict[dict[dict]] | None = None  # TODO: implement this
    session_create: bool | None = None
    legacy_timers: bool | None = None
    associated_bundle_identifiers: str | list[str] | None = None

    @pydantic.model_validator(mode="after")
    def validate(self) -> typing.Self:
        if self.init_groups and not self.user_name:
            raise ValueError("user_name must be set when init_groups is set")

        if self.legacy_timers and self.process_type != "Interactive":
            raise ValueError("legacy_timers effects only when process_type is set to Interactive")

        if isinstance(self.keep_alive, ServiceKeepAlive):
            if self.keep_alive.successful_exit is not None and not self.run_at_load:
                raise ValueError("run_at_load must be set when keep_alive.successful_exit is set")

        return self

    def build(self, result_dir: pathlib.Path, job_name: str, domain_name: str) -> pathlib.Path:
        target_reverse_domain_name: str = ".".join([*reversed(domain_name.split(".")), job_name])
        self.label = target_reverse_domain_name

        plist_path = result_dir / f"{target_reverse_domain_name}.plist"
        plist_path.unlink(missing_ok=True)
        plist_path.write_bytes(
            plistlib.dumps(
                self.model_dump(
                    mode="json",
                    by_alias=True,
                    exclude_unset=True,
                    exclude_none=True,
                    exclude_defaults=True,
                )
            )
        )
        return plist_path
