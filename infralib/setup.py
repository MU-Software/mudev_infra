import os

import setuptools

# allow setup.py to be run from any path
os.chdir(os.path.normpath(os.path.join(os.path.abspath(__file__), "../..")))

setuptools.setup(name="infralib", version="0.1", packages=setuptools.find_packages())
