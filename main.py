import functools
import pathlib
import shutil

import dotenv
import jinja2
import yaml

import infralib.struct.config as config_struct


@functools.cache
def get_dotenv_data(config_dir: pathlib.Path) -> dict:
    return dotenv.dotenv_values(config_dir / ".env")


@functools.cache
def get_config_data(config_dir: pathlib.Path) -> config_struct.Config:
    config_template: jinja2.Template = jinja2.Template((config_dir / "config.yaml").read_text())
    config_string: str = config_template.render(get_dotenv_data(config_dir))
    return config_struct.Config.model_validate(yaml.safe_load(config_string))


def main(base_dir: pathlib.Path):
    config_dir = base_dir / "config"
    template_dir = base_dir / "template"
    build_result_dir = base_dir / "build"

    if build_result_dir.exists():
        shutil.rmtree(build_result_dir)
    build_result_dir.mkdir(parents=True, exist_ok=True)

    target: list[str] = ["service", "dotenv"]
    for t in target:
        template_dir = template_dir / t
        build_dir = build_result_dir / t
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
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--base-dir", required=True)
    args = parser.parse_args()

    if not (args.base_dir and (base_dir := pathlib.Path(args.base_dir)).exists()):
        raise FileNotFoundError(f"base_dir not found: '{args.base_dir}'")

    main(base_dir=base_dir.resolve())
