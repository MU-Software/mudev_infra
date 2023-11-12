import functools
import pathlib
import shutil

import dotenv
import jinja2
import yaml

import infralib.struct.config as config_struct
import infralib.struct.launchd_plist as launchd_plist_struct

BASE_DIR = pathlib.Path(__file__).parent
CONFIG_DIR = BASE_DIR / "config"
TEMPLATE_DIR = BASE_DIR / "template"
BUILD_RESULT_DIR = BASE_DIR / "build"


@functools.cache
def get_dotenv_data() -> dict:
    return dotenv.dotenv_values(CONFIG_DIR / ".env")


@functools.cache
def get_config_data() -> config_struct.Config:
    config_template: jinja2.Template = jinja2.Template((CONFIG_DIR / "config.yaml").read_text())
    config_string: str = config_template.render(get_dotenv_data())
    return config_struct.Config.model_validate(yaml.safe_load(config_string))


def main():
    if BUILD_RESULT_DIR.exists():
        shutil.rmtree(BUILD_RESULT_DIR)
    BUILD_RESULT_DIR.mkdir(parents=True, exist_ok=True)

    target: list[str] = ["service", "dotenv"]
    for t in target:
        template_dir = TEMPLATE_DIR / t
        build_dir = BUILD_RESULT_DIR / t
        build_dir.mkdir(parents=True, exist_ok=True)

        env_vars = get_dotenv_data()
        config_collection: dict[str, config_struct.ConfigDetailWithMatrix] = getattr(get_config_data(), t)

        for template_file in template_dir.iterdir():
            if not template_file.is_file():
                continue

            result_files: list[pathlib.Path]
            if target_config := config_collection.get(template_file.name):
                result_files = target_config.build(template_file, build_dir, env_vars)
            else:
                result_files = [config_struct.build_file(template_file, build_dir, env_vars)]

            if t == "service":
                for result_file in result_files:
                    launchd_plist_struct.Service.model_validate(yaml.safe_load(result_file.read_text())).build(
                        build_dir,
                        result_file.stem,
                        env_vars["DOMAIN_NAME"],
                    )


if __name__ == "__main__":
    main()
