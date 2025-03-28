# Configuring GitHub Actions for Continuous Integration and Deployment

**This video serves as a complementary guide to the [Simple GCP Containers](https://youtu.be/9q0hXgSssPI) video**, where we explored deploying a Python-based microservice using the Flask framework using containers in Google Cloud. In this new series, we will build upon the original project by configuring **GitHub Actions** to automate the build, test, and deployment processes entirely within the GitHub ecosystem.

GitHub Actions is a powerful CI/CD (Continuous Integration and Continuous Deployment) tool that allows developers to automate workflows directly within their GitHub repositories. By leveraging GitHub Actions, you can streamline your development pipeline, reduce manual errors, and ensure consistent deployments across environments.

Below, we’ll walk through the steps required to configure GitHub Actions for your project. These steps assume you have a basic understanding of GitHub, Terraform, and containerized applications.

---

## Steps to Configure GitHub Actions

### 1. **Create a New GitHub Repository from a Template Repository**
   - Navigate to the source repository in a browser.

      ```bash
        https://github.com/mamonaco1973/gcp-flask-container
      ```

   - The source repository is a template repository so you will need to create your repository from the template. To create your repository from a template, navigate to template repository repository on GitHub, click the **"Use this template"** button, and follow the prompts to create your new repository.

      ![template](use_this_template.png) 

### 2. **Clone the New Repository to Your Local Environment**
   - Once your repository is created, clone it to your local machine using the following command:
     ```bash
     git clone https://github.com/your-username/your-new-repo.git
     ```
   - Navigate into the cloned repository directory:
     ```bash
     cd your-new-repo
     ```

### 3. **Run `terraform apply` on the `00-backend` Directory**
   - The `00-backend` directory contains Terraform configuration files to set up the necessary remote state infrastructure for your project. Run the following commands to initialize and apply the Terraform configuration:
     ```bash
     ./check_env.sh
     cd 00-backend
     terraform init
     terraform apply
     ```
   - Review the proposed changes and confirm by typing `yes` when prompted. This step will provision the required cloud resources, such as storage buckets or networking components, depending on your project's needs.
   - In Terraform, the **backend** is used to store the **state file** in a shared location, which is a critical component of Terraform's operation. The state file (`terraform.tfstate`) contains:

      - **Resource Mapping**: It tracks the mapping between the resources defined in your Terraform configuration (e.g., `.tf` files) and the actual resources provisioned in your cloud environment.
      - **Metadata**: It stores metadata about the resources, such as their current state, dependencies, and attributes (e.g., IP addresses, IDs, etc.).
      - **Synchronization**: It enables collaboration by allowing multiple team members to work on the same infrastructure without conflicts, as the state file acts as the single source of truth.
      - **Locking**: Backends like AWS S3 or Terraform Cloud support state locking, which prevents concurrent operations that could corrupt the state file.

  - Why a Backend Configuration is Needed:
      - **Persistence**: Without a backend, the state file is stored locally by default, which is risky. If the file is lost or corrupted, Terraform loses track of the infrastructure it manages.
      - **Collaboration**: A remote backend allows teams to share and manage the state file centrally, enabling seamless collaboration.
      - **Security**: Storing the state file remotely (e.g., in an S3 bucket or Terraform Cloud) ensures it is encrypted and access-controlled, reducing the risk of unauthorized changes.
      - **Automation**: Remote backends integrate with CI/CD pipelines, enabling automated infrastructure management.

### 4. **Examine and Push the Backend Files to the Repository**
   - Check to see that `01-gar/01-gar-backend.tf` was created. The content should look something like this:

     ```hcl
      terraform {
         backend "gcs" {
            bucket = "terraform-state-hknoss"
            prefix = "terraform/01-gar/state"
         }
      }
     ```
   - Check to see that `03-cloudrun/03-cloudrun-backend.tf` was created. The content should look something like this:

     ```hcl
      terraform {
        backend "gcs" {
           bucket = "terraform-state-hknoss"
          prefix = "terraform/03-cloudrun/state"
         }
      }
     ```

   - After successfully applying the Terraform configuration, commit and push the backend files to your GitHub repository:
     ```bash
     cd ..
     git add .
     git commit -m "Configured backend infrastructure using Terraform"
     git push origin main
     ```

### 5. **Configure GitHub Secrets for the Build Process**
   - GitHub Secrets are encrypted environment variables that allow you to securely store sensitive information, such as API keys, credentials, or deployment tokens. To configure secrets:
     1. Navigate to your repository on GitHub.
     2. Go to **Settings** > **Secrets and variables** > **Actions**.
     3. Click **New repository secret** and add the following secret:

         - `GCP_CREDENTIALS_JSON`: The JSON credentials for authenticating with Google Cloud Platform.

   - These secrets will be used in your GitHub Actions workflow to authenticate with external services during the build and deployment process.

### 6. **Test the GitHub Actions Workflow**
   - With the repository and secrets configured, it's time to test your GitHub Actions workflow. GitHub Actions workflows are defined in YAML files located in the `.github/workflows/` directory of your repository.
   - To manually trigger and test an existing workflow from the GitHub website:
     1. Navigate to your repository on GitHub.
     2. Click on the **Actions** tab at the top of the repository page.
     3. In the left sidebar, you’ll see a list of all the workflows defined in your repository. Click on the workflow you want to run (e.g., `Build Solution`).
     4. On the workflow’s page, click the **Run workflow** button in the top-right corner.
     5. If the workflow requires inputs (e.g., a branch name or specific parameters), you’ll be prompted to provide them. Select the appropriate options and click **Run workflow**.
     6. The workflow will start executing, and you can monitor its progress in real-time. Each step of the workflow will be displayed, along with logs and output for debugging.
     7. Once the workflow completes, you’ll see a summary of the results, including whether it succeeded or failed. If it fails, review the logs to identify and fix any issues.

   - This process allows you to manually test and validate your workflows before relying on automated triggers (e.g., push or pull request events).
   

## Quick Links

1. [Simple Cloud Containers: Docker Containers in AWS, Azure, and GCP](https://youtu.be/2BQB-OMAhH8)
2. [GitHub Actions](https://youtu.be/Ngsz9pfgBUo)
3. AWS Solution
   - [Simple AWS Containers](https://youtu.be/hhtDigvwMwk)
   - [AWS GitHub Actions](https://youtu.be/FQPjUdQ4hLM)
   - [GitHub Project](https://github.com/mamonaco1973/aws-flask-container/)
4. Azure Solution
   - [Simple Azure Containers](https://youtu.be/eogMQjbBvTo)
   - [Azure GitHub Actions](https://youtu.be/MGzcVCAfouQ)
   - [GitHub Project](https://github.com/mamonaco1973/azure-flask-container/)
5. GCP Solution
   - [Simple GCP Containers](https://youtu.be/9q0hXgSssPI)
   - [GCP GitHub Actions](https://youtu.be/ZMlJ_Cj7tY0)
   - [GitHub Project](https://github.com/mamonaco1973/gcp-flask-container/)
