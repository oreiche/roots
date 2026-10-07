# Debug option to replace real image builds by downloads from cdimage
DEBUG_FAKE_BUILD_LIVEFS = False

# Constructor for a product definition (only accept arguments supported by build_image_job, see below)
def image_product(project, subproject, arch, subarch="", pocket="Updates", timeout=2*60*60):
    return dict(
        project=project,
        subproject=subproject,
        arch=arch,
        subarch=subarch,
        pocket=pocket,
        timeout=timeout,
    )

# Register and return a new image build job (via builtin 'build_livefs')
def build_image_job(name, stage, series, product):
    if DEBUG_FAKE_BUILD_LIVEFS:
        return fake_build_image_job(name, stage, series, product)
    return job(
            name=name,
            stage=stage,
            type="builtin",
            call="build_livefs",
            args=dict(
                lfs_name="-".join(["zazu", series]),
                dist="ubuntu",
                series=series,
                **product,
            ),
        )

# Register and return a new static validation test job
# - writes output.log and iso_static_validation.yaml
# - note: UTAH was modified to skip the sha256 check with cdimage's SHA256SUMS
def test_static_validation_job(name, stage, deps):
    def test_static_validation_task(dep_infos):
        root = {}
        outs = ['output.log', 'iso_static_validation.yaml']
        cmds = ['touch output.log iso_static_validation.yaml']
        for info in dep_infos:
            data = info["data"]
            artifacts = info["artifacts"]
            if "build_livefs" in data:
                # this is a build_livefs job
                # -> get image for testing and write test command
                image_file_name = data["build_livefs"]["image"]
                image_path = 'images/' + image_file_name
                root[image_path] = artifacts[image_file_name]
                cmds += [
                    # first make sure the image path can be read by user 'utah'
                    'PARENT="$(dirname "$(pwd)/{}")"'.format(image_path),
                    'while [ "$PARENT" != "/" ]; do chmod 755 "$PARENT" || true; PARENT="$(dirname "$PARENT")"; done',
                    # run the utah static validation
                    'sudo -u utah -i /usr/share/utah/isotest/iso_static_validation.py --name "$(pwd)/{}" >output.log 2>&1'.format(image_path),
                    # obtain the test log
                    'cp "$(grep \'/var/log/.*yaml$\' output.log | xargs)" iso_static_validation.yaml',
                ]
        return {
            "inputs": root,
            "outputs": outs,
            "data": {
                "iso_static_validation": {
                    "output": "output.log",
                    "logfile": "iso_static_validation.yaml",
                }
            },
            "env": {},
            "cmds": cmds,
        }
    return job(
        name=name,
        stage=stage,
        type="generic",
        call=test_static_validation_task,
        deps=deps,
        queue="utah",
    )

# Register and return a new extensive test job (mockup using sleep, placeholder for now)
def test_release_job(name, stage, deps):
    def test_release_task(dep_infos):
        root = {}
        outs = ['test.log']
        cmds = ['sleep 60s', 'echo PASS > test.log']
        return {
            "inputs": root,
            "outputs": outs,
            "data": {"test_release": {"logfile": "test.log"}},
            "env": {},
            "cmds": cmds,
        }
    return job(
        name=name,
        stage=stage,
        type="generic",
        call=test_release_task,
        deps=deps,
    )

# Register fake image build job: uses generic job producing the same output
def fake_build_image_job(name, stage, series, product):
    def fake_build_livefs(dep_infos):
        project = product["project"]
        subproject = product["subproject"]
        arch = product["arch"]

        isoname = 'MISSING'
        if project == 'ubuntu':
            isoname = '{}-desktop-{}.iso'.format(series, arch)
        elif project == 'ubuntu-server':
            isoname = '{}-{}-server-{}.iso'.format(series, subproject, arch)
        url = 'https://cdimage.ubuntu.com/{}/{}/daily-{}/current/{}'.format(project, series, subproject, isoname)

        image = 'livecd.{}.iso'.format(project)
        manifest = 'livecd.{}.manifest'.format(project)

        outs = [image, manifest, 'build.log']
        cmds = [
            'touch {} build.log'.format(manifest),
            'wget {} -O {} >/dev/null 2>&1'.format(url, image),
        ]
        return {
            "inputs": {},
            "outputs": outs,
            "data": {
                "build_livefs": {
                    "image": 'livecd.{}.iso'.format(product["project"]),
                    "manifest": 'livecd.{}.manifest'.format(product["project"]),
                    "build_log": 'build.log',
                }
            },
            "env": {},
            "cmds": cmds,
        }
    return job(
        name=name,
        stage=stage,
        type="generic",
        call=fake_build_livefs,
        deps=[],
    )
