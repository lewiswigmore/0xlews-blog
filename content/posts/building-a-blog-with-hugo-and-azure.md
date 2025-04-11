+++
title = 'Building a Blog with Azure and Hugo'
date = 2024-11-03T15:30:00+01:00
draft = false
tags = ["azure", "tutorial", "dev", "web apps"]
categories = ["Azure", "Web Development"]
description = "A practical guide to creating your own cybersecurity blog using Hugo and hosting it on Azure Static Web Apps"
+++

# Building a blog with Hugo and Azure

I recently set up this blog using Hugo and Azure Static Web Apps, and I wanted to share the process. This approach provides a fast, secure, and cost-effective (free!) way to run a technical blog. Here's how I did it from scratch.

## Why This Stack?

- **Hugo**: Really fast static site generator with great Markdown support and documentation on how to integrate with Azure Statis Web Apps
- **PaperMod theme**: Clean design with dark mode and code highlighting etc
- **Azure Static Web Apps**: Free tier available, easy deployment, and global CDN

## Prerequisites

- Git
- Azure account

## Step 1: Install Hugo

First, let's get Hugo installed. I created a project folder and downloaded Hugo:

```bash
# Create project directory
mkdir my-blog
cd my-blog

# Download and extract Hugo (Windows example)
# For other platforms, see the Hugo documentation
curl -L https://github.com/gohugoio/hugo/releases/download/v0.125.7/hugo_0.125.7_windows-amd64.zip -o hugo.zip
mkdir bin
unzip hugo.zip -d bin
```

## Step 2: Create a New Hugo Site

Now we can use Hugo to create the initial site structure:

```bash
./bin/hugo new site . --force
```

## Step 3: Install the PaperMod Theme

PaperMod is perfect for a tech related blog with built-in dark mode and code highlighting. It's also just so clean:

```bash
git init
git submodule add https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod
```

## Step 4: Configure Hugo

Create a `hugo.toml` configuration file (or edit the existing one) to set up your blog:

```toml
baseURL = "/"
languageCode = "en-us"
title = "My Security Blog"
theme = "PaperMod"

# Enable syntax highlighting for code blocks
pygmentsUseClasses = true
pygmentsCodeFences = true

# Enable Archive functionality
[taxonomies]
category = "categories"
tag = "tags"
series = "series"

# Enable search page
[outputs]
home = ["HTML", "RSS", "JSON"]

[params]
# Default theme "auto", "light", "dark"
defaultTheme = "dark"
disableThemeToggle = false

# Enable search
enableSearch = true
enableRobotsTXT = true

# Show reading time on posts
ShowReadingTime = true

# Show table of contents
ShowToc = true
TocOpen = false

# Show post navigation (prev/next)
ShowPostNavLinks = true

# Show breadcrumbs
ShowBreadCrumbs = true

# Show code copy buttons
ShowCodeCopyButtons = true

# Show word count
ShowWordCount = true

# Show last modified date
ShowLastMod = true

[params.homeInfoParams]
Title = "My Security Blog"
Content = """
A technical blog focused on cybersecurity, penetration testing, and secure coding practices.
"""

[[menu.main]]
identifier = "categories"
name = "Categories"
url = "/categories/"
weight = 10

[[menu.main]]
identifier = "tags"
name = "Tags"
url = "/tags/"
weight = 20

[[menu.main]]
identifier = "archives"
name = "Archives"
url = "/archives/"
weight = 30

[[menu.main]]
identifier = "search"
name = "Search"
url = "/search/"
weight = 40
```

## Step 5: Create Required Directories and Pages

We need to create a few key files for the navigation elements:

```bash
# Create archives page
mkdir -p content/archives
echo '---
title: "Archives"
layout: "archives"
url: "/archives/"
summary: "archives"
---' > content/archives/index.md

# Create search page
mkdir -p content/search
echo '---
title: "Search"
layout: "search"
---' > content/search/index.md
```

## Step 6: Create Your First Post

Now let's create your first blog post:

```bash
./bin/hugo new posts/welcome-post.md
```

Then edit the created file at `content/posts/welcome-post.md` to add your content. Here's a simple example that includes code blocks and formatting:

```markdown
+++
title = 'Welcome to My Security Blog'
date = 2025-04-02T12:00:00+01:00
draft = false
tags = ["security", "introduction"]
categories = ["General"]
description = "Welcome to my blog focused on all things cyber!"
+++

# Welcome to My Security Blog

Hello and welcome to my cybersecurity blog! I'm excited to share tutorials, practical tips, and my real-world security experiences with you.

## What to Expect

This blog will focus on various cybersecurity topics including:

- Penetration testing
- Vulnerability research
- Digital forensics

## Sample Code Block

Here's an example of how code blocks will appear on this blog:

```python
#!/usr/bin/env python3
import socket
import sys

def simple_port_scan(target, port_range):
    """Simple port scanner function"""
    open_ports = []
    
    for port in range(port_range[0], port_range[1] + 1):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)
        result = sock.connect_ex((target, port))
        if result == 0:
            open_ports.append(port)
        sock.close()
    
    return open_ports

if __name__ == "__main__":
    target = "127.0.0.1"  # Example target
    ports = simple_port_scan(target, (1, 1024))
    print(f"Open ports on {target}: {ports}")
```

Happy hacking (ethically, of course lol;)
```

## Step 7: Test Site Locally

Now let's test to make sure everything is working:

```bash
./bin/hugo server -D
```

Visit `http://localhost:1313/` in your browser to see your site.

## Step 8: Build Your Site for Production

Once you're happy with your site, build it for production:

```bash
./bin/hugo
```

This creates all the static files in the `public` directory.

## Step 9: Configure Azure Static Web Apps

Create a `staticwebapp.config.json` file in your project root to handle routing properly:

```json
{
  "trailingSlash": "auto",
  "routes": [
    {
      "route": "/assets/*",
      "headers": {
        "cache-control": "public, max-age=31536000, immutable"
      }
    }
  ],
  "responseOverrides": {
    "404": {
      "rewrite": "/404.html"
    }
  }
}
```

## Step 10: Create Azure Resources

Now we'll create the necessary resources in Azure:

```bash
# Login to Azure
az login

# Create a resource group
az group create --name my-blog-rg --location westeurope

# Create the Static Web App
az staticwebapp create --name my-blog --resource-group my-blog-rg --location westeurope --source /path/to/your/blog --output-location public --branch master
```

During this process, you'll be given a token. Save it securely - you'll need it for future deployments.

## Step 11: Set Up Secure Credential Management

Create a `.env` file to store your deployment token securely:

```bash
touch .env
echo "AZURE_DEPLOYMENT_TOKEN=your-token-here" >> .env
echo ".env" >> .gitignore
```

Then create a deployment script (saves a lot of time in the future):

```bash
touch deploy.sh
echo '#!/bin/bash
source .env
./bin/hugo
swa deploy ./public --deployment-token $AZURE_DEPLOYMENT_TOKEN --env production' > deploy.sh
chmod +x deploy.sh
```

## Step 12: Deploy Your Blog

Finally, deploy your site using the Azure Static Web Apps CLI:

```bash
# Install the Azure Static Web Apps CLI
npm install -g @azure/static-web-apps-cli

# Deploy using your script
./deploy.sh
```

Your site will be available at the URL provided after deployment completes (usually something like `https://[random-name].[region].azurestaticapps.net`).

## Maintaining Your Blog

To add new posts, simply:

1. Create a new markdown file: `./bin/hugo new posts/my-new-post.md`
2. Edit the file with your content
3. Run `./deploy.sh` to rebuild and deploy your site

## Conclusion

You now have a fully functioning, secure, and modern blog running on Azure Static Web Apps. This setup gives you:

- Free hosting
- Fast page loads because of Azure's global CDN
- Secure HTTPS by default
- Easy content management through Markdown
- Version control through Git
- Dark mode ;)

If you run into any issues, check the [Hugo documentation](https://gohugo.io/documentation/) or [Azure Static Web Apps documentation](https://learn.microsoft.com/en-us/azure/static-web-apps/publish-hugo/).

And you are done!