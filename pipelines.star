# load core template functions
load("core/core.star", "build_image_job", "test_static_validation_job", "test_release_job")

# load product definition getters (renamed to avoid conflicts)
load("ubuntu/products.star", ubuntu_defs="defs")
load("ubuntu-server/products.star", server_defs="defs")
load("ubuntu-mini-iso/products.star", miniiso_defs="defs")
load("ubuntu-budgie/products.star", budgie_defs="defs")
load("ubuntu-mate/products.star", mate_defs="defs")

# globals
SERIES = "resolute"


# helper function for parsing mandatory configuration values
def get_channel():
    channel = getenv("channel")

    if not channel:
        fail("mandatory channel variable is missing")
    elif channel not in ["daily", "release"]:
        fail("unknown channel '{}', supported values are: 'daily', 'release'".format(channel))

    return channel


# helper function for generating non-conflicting pipeline name from product
def gen_pipeline_name(product):
    arch = product["arch"]
    if product["subarch"]:
        arch = "{}+{}".format(arch, product["subarch"])
    return "{}_{}_{}".format(product["project"], product["subproject"], arch)


def register_pipelines():
    pipelines = []

    # parse configuration variables from env
    channel = get_channel()

    for defs in [ubuntu_defs, server_defs, miniiso_defs, budgie_defs, mate_defs]:
        for product in defs.products():
            # add image build job for product
            jobs = [
                build_image_job(
                    name="build_image",
                    stage="build",
                    series=SERIES,
                    product=product,
                ),
            ]

            # add tests jobs defined by product
            jobs += defs.test_jobs(channel, "build_image")

            # create and add pipeline with defined jobs
            pipelines += [
                pipeline(
                    name=gen_pipeline_name(product),
                    groups=["image", product["arch"]],
                    stages=["build", "test"],
                    jobs=jobs,
                )
            ]

    return pipelines
