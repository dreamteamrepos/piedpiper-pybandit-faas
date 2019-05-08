import os
import tempfile
import sh
from io import StringIO
from .util import unzip_files


def handle(request):
    """
    handle a request to the function
    Args:
        request (str): request body
    """
    zip_file = request.files.getlist('files')[0]
    bandit_reports = []
    with tempfile.TemporaryDirectory() as tmpdir:
        unzip_files(zip_file, tmpdir)
        os.chdir(tmpdir)
        project_directories = [
            name
            for name in os.listdir(".")
            if os.path.isdir(name)
        ]
        for project_directory in project_directories:
            report = run_bandit(project_directory)
            bandit_reports.append(report)
    return '\n'.join(bandit_reports)


def run_bandit(directory):
    buf = StringIO()
    try:
        sh.bandit(
            '--recursive',
            '-ftxt',
            directory,
            _out=buf,
            _err_to_out=True,
        )
    except (sh.ErrorReturnCode_1, sh.ErrorReturnCode_2):
        pass
    return buf.getvalue()
