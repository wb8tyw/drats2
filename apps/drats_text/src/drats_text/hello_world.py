#!/bin/python
'''Hello World Template program.'''

import logging
from os.path import basename

from pathlib import Path
import version_git

def main():

    '''Main package for testing.'''
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(basename(__file__))

    my_dir = Path(__file__).resolve().parent
    version_info = version_git.VersionGit(project_path=my_dir, logger=logger)

    logger.info("VERSION:        %s", version_info.full_version)
    logger.info("PEP440_VERSION: %s", version_info.pep440_version)
    logger.info("NAME:           %s", version_info.project_info['name'])
    logger.info("DESCRIPTION:    %s", version_info.project_info['description'])
    logger.info("AUTHORS:        %s", version_info.project_info['authors'])
    logger.info("LICENSE:        %s", version_info.project_info['license'])
    logger.info("WEBSITE:        %s", version_info.project_info['homepage'])

if __name__ == "__main__":
    main()
