# Poor man's anonymous phishing infrastructure

Details of this project can be found in [this blog post](https://ttp.report/phishing/2023/09/18/abusing-cloud-poor-man-phishing.html).

Note, that the Terraform manifest is non-convergent, because it provisions both infra and code (yeah, I know). On top of that, Terraform deprecated ability to make resource depend on local file, so it will require running deployment twice to properly provision both.
