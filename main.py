import enum
import functools
import pathlib
import shutil
import subprocess

import dotenv
import jinja2
import typer
import yaml

import infralib.struct.config as config_struct

app = typer.Typer()


class SOPSmode(enum.StrEnum):
    ENCRYPT = enum.auto()
    DECRYPT = enum.auto()

    @property
    def flag(self) -> str:
        return f"-{self.name.lower()[0]}"


def resolve_sops_bin_path() -> pathlib.Path | None:
    result = shutil.which("sops")
    return pathlib.Path(result) if result else None


def sops_exec(mode: SOPSmode, in_path: pathlib.Path, sops_bin_path: pathlib.Path) -> str:
    return subprocess.run(
        [sops_bin_path.resolve().as_posix(), mode.flag, in_path.resolve().as_posix()],
        capture_output=True,
        check=True,
        text=True,
    ).stdout


@app.command()
def sops(mode: str, in_dir: pathlib.Path, out_dir: pathlib.Path) -> None:
    if not (in_dir := in_dir.resolve()).exists():
        raise FileNotFoundError(f"{in_dir} is not found")

    if (out_dir := out_dir.resolve()).exists():
        shutil.rmtree(out_dir)

    if not (sops_bin_path := resolve_sops_bin_path()):
        raise FileNotFoundError("sops is not found")

    resolved_mode: SOPSmode = SOPSmode(mode)

    for f in in_dir.rglob("*"):
        if not f.is_file():
            continue

        output_path = (out_dir / f.relative_to(in_dir))
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(sops_exec(in_path=f, mode=resolved_mode, sops_bin_path=sops_bin_path))

    return None


@functools.cache
def get_dotenv_data(config_dir: pathlib.Path) -> dict:
    return dotenv.dotenv_values(config_dir / ".env")


@functools.cache
def get_config_data(config_dir: pathlib.Path) -> config_struct.Config:
    config_template: jinja2.Template = jinja2.Template((config_dir / "config.yaml").read_text())
    config_string: str = config_template.render(get_dotenv_data(config_dir))
    return config_struct.Config.model_validate(yaml.safe_load(config_string))


@app.command()
def build(in_dir: pathlib.Path, out_dir: pathlib.Path):
    config_dir = in_dir / "config"
    template_dir = in_dir / "template"

    if out_dir.exists():
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    target: list[str] = ["service", "dotenv"]
    for t in target:
        template_dir = template_dir / t
        build_dir = out_dir / t
        build_dir.mkdir(parents=True, exist_ok=True)

        env_vars = get_dotenv_data(config_dir)
        config_collection: dict[str, config_struct.ConfigDetailWithMatrix] = getattr(get_config_data(config_dir), t)

        for template_file in template_dir.iterdir():
            if not template_file.is_file():
                continue

            # result_files: list[pathlib.Path]
            if target_config := config_collection.get(template_file.name):
                target_config.build(template_file, build_dir, env_vars)
            else:
                [config_struct.build_file(template_file, build_dir, env_vars)]


if __name__ == "__main__":
    app()
