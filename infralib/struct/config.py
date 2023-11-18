import pathlib
import string

import jinja2
import pydantic
import yaml

import infralib.struct.launchd_plist as launchd_plist_struct


def build_file(
    template_path: pathlib.Path,
    result_dir: pathlib.Path,
    env_vars: dict[str, str],
    link_to: list[pathlib.Path] | None = None,
) -> pathlib.Path:
    env_vars = env_vars or {}
    link_to = link_to or []

    template: jinja2.Template = jinja2.Template(template_path.read_text())
    template_string: str = template.render(env_vars)

    result_name: str = string.Template(template_path.stem).substitute(env_vars)
    result_path: pathlib.Path = result_dir / f"{result_name}{template_path.suffix}"
    result_path.write_text(template_string)

    for link in link_to:
        if (symlink_path := pathlib.Path(link)).exists():
            symlink_path.unlink()
        symlink_path.symlink_to(result_path)

    return result_path


def build_service_file(
    template_path: pathlib.Path,
    result_dir: pathlib.Path,
    env_vars: dict[str, str],
    link_to: list[pathlib.Path] | None = None,
) -> pathlib.Path:
    result_file = build_file(template_path, result_dir, env_vars, link_to)
    result_data = yaml.safe_load(result_file.read_text())
    model_data = launchd_plist_struct.Service.model_validate(result_data)
    model_data.build(result_dir, result_file.stem, env_vars["DOMAIN_NAME"])

    for link in link_to:
        if (symlink_path := pathlib.Path(link)).exists():
            symlink_path.unlink()
        symlink_path.symlink_to(result_file)

    return result_file


class ConfigDetail(pydantic.BaseModel):
    linkTo: list[pydantic.FilePath | pydantic.NewPath] = pydantic.Field(default_factory=list)
    variables: dict[str, str] = pydantic.Field(default_factory=dict)


class ConfigDetailWithMatrix(ConfigDetail):
    matrix: list[ConfigDetail] = pydantic.Field(default_factory=list)

    def build(
        self,
        template_path: pathlib.Path,
        result_dir: pathlib.Path,
        global_vars: dict[str, str] | None = None,
    ) -> list[pathlib.Path]:
        return [
            build_file(
                template_path,
                result_dir,
                {**matrix.variables, **self.variables, **(global_vars or {})},
                matrix.linkTo + self.linkTo,
            )
            for matrix in (self.matrix or [ConfigDetail()])
        ]


class ServiceConfigDetailWithMatrix(ConfigDetailWithMatrix):
    def build(
        self,
        template_path: pathlib.Path,
        result_dir: pathlib.Path,
        global_vars: dict[str, str] | None = None,
    ) -> list[pathlib.Path]:
        return [
            build_service_file(
                template_path,
                result_dir,
                {**matrix.variables, **self.variables, **(global_vars or {})},
                matrix.linkTo + self.linkTo,
            )
            for matrix in (self.matrix or [ConfigDetail()])
        ]


class Config(pydantic.BaseModel):
    service: dict[str, ServiceConfigDetailWithMatrix] = pydantic.Field(default_factory=dict)
    dotenv: dict[str, ConfigDetailWithMatrix] = pydantic.Field(default_factory=dict)
