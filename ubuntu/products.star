# load core template function for defining an image product
load("core/core.star", "image_product", "test_static_validation_job", "test_release_job")

def products(series):
    products = [
        image_product(project="ubuntu", subproject="live", arch="amd64"),
        image_product(project="ubuntu", subproject="live", arch="arm64"),
        image_product(project="ubuntu", subproject="live", arch="riscv64", timeout=12*60*60),
        image_product(project="ubuntu", subproject="preinstalled", arch="arm64", subarch="raspi"),
    ]

    if series == "stonking":
        products += [image_product(project="ubuntu", subproject="live", arch="amd64v3")]

    return products


def test_jobs(series, channel, build_job):
    jobs = [
        test_static_validation_job(name="static_validation", stage="test", deps=[build_job]),
    ]

    if channel == "release":
        jobs += [test_release_job(name="test_release", stage="test", deps=[build_job])]

    return jobs


defs = dict(
    products = products,
    test_jobs = test_jobs,
)