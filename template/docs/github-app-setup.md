# GitHub App Setup for Reviewer Identity

This guide explains how to create and configure a GitHub App so the Reviewer agent can post
approvals using a separate identity. GitHub does not allow self-approvals — a PR author cannot
approve their own PR. By using a GitHub App with its own installation token, the Reviewer agent
approves PRs under a distinct identity even when running as the same OS user.

## 1. Create a GitHub App

1. Go to your GitHub account → **Settings** → **Developer settings** → **GitHub Apps**
   (or navigate to `https://github.com/settings/apps/new` for a personal account app)
2. Fill in the required fields:
   - **GitHub App name**: Choose a unique name (e.g., `my-project-reviewer`)
   - **Homepage URL**: Use the repository URL
   - **Webhook**: Uncheck "Active" — no webhook needed
3. Under **Permissions**, set:
   - **Repository permissions**:
     - `Pull requests`: **Read and write** (required for posting reviews)
     - `Contents`: **Read-only** (required for checking out code)
4. Under **Where can this GitHub App be installed?**, select **Only on this account**
5. Click **Create GitHub App**
6. Note the **App ID** shown at the top of the app's settings page — you will need this

## 2. Generate and Download a Private Key

1. On the GitHub App settings page, scroll to **Private keys**
2. Click **Generate a private key**
3. A `.pem` file downloads automatically
4. Move the file to a stable location (it must stay there — the path goes in your credentials file):
   ```sh
   mkdir -p ~/.config/godot-reviewer-app
   mv ~/Downloads/*.private-key.pem ~/.config/godot-reviewer-app/private-key.pem
   chmod 600 ~/.config/godot-reviewer-app/private-key.pem
   ```

## 3. Install the App on the Repository

1. On the GitHub App settings page, click **Install App** in the left sidebar
2. Select your account
3. Choose **Only select repositories** → select your repository
4. Click **Install**
5. After installation, look at the URL in your browser — it ends with `/installations/<number>`
6. Note that number — it is your **Installation ID**

## 4. Store Credentials

Create the credentials file at `~/.config/godot-reviewer-app/app-credentials.json`:

```json
{
  "app_id": "<your-app-id>",
  "private_key_path": "/home/<you>/.config/godot-reviewer-app/private-key.pem",
  "installation_id": "<your-installation-id>"
}
```

**Schema reference:**

| Field | Type | Description |
|---|---|---|
| `app_id` | string | The numeric App ID from step 1 |
| `private_key_path` | string | Absolute path to the `.pem` private key file |
| `installation_id` | string | The numeric Installation ID from step 3 |

**Security:**
- Use absolute paths — the path is passed directly to `openssl`
- Ensure the `.pem` file has mode `600` (no group or world read)
- Never commit either file — `.gitignore` already excludes `*.pem` and `reviewer-app.env`

## 5. Verify Setup

Generate a test token to confirm everything is configured correctly:

```sh
./scripts/tools/gh-app-token.sh
```

If successful, a token string is printed to stdout (it looks like `ghs_...`).

If it fails, check:
- `~/.config/godot-reviewer-app/app-credentials.json` exists and is valid JSON
- `private_key_path` in the credentials file points to the actual `.pem` file
- The `.pem` file is readable by your current user
- The App is installed on the repository (step 3)
- `jq` and `openssl` are available in your PATH
