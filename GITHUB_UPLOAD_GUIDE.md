# 🚀 GitHub Upload Guide

This guide will help you upload your Customer 360 & AI Assistant demo to GitHub.

## 📋 Prerequisites

- GitHub account
- Git installed on your computer
- Terminal/Command Prompt access

## 🔧 Step 1: Create a GitHub Repository

1. Go to [GitHub.com](https://github.com) and sign in
2. Click the green "New" button (or the "+" icon → "New repository")
3. Fill in repository details:
   - **Repository name**: `customer-360-demo` (or your preferred name)
   - **Description**: `Snowflake-native Customer 360 & AI Assistant demo with real-time analytics`
   - **Visibility**: Choose Public or Private
   - ✅ Check "Add a README file" (we'll replace it)
   - ✅ Check "Add .gitignore" and select "Python"
   - Choose a license (MIT recommended)
4. Click "Create repository"

## 💻 Step 2: Prepare Your Local Files

Open your terminal and navigate to your project directory:

```bash
cd /Users/jasvestis/cursor
```

Verify all files are present:
```bash
ls -la
```

You should see:
```
├── README.md
├── sql/
├── streamlit/
├── scripts/
├── docs/
└── GITHUB_UPLOAD_GUIDE.md
```

## 🔄 Step 3: Initialize Git (if not already done)

```bash
# Initialize git repository
git init

# Add GitHub repository as remote (replace YOUR_USERNAME and YOUR_REPO_NAME)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
```

## 📦 Step 4: Create .gitignore File

Create a `.gitignore` file to exclude sensitive files:

```bash
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual Environment
venv/
env/
ENV/
.venv/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Environment variables
.env
.env.local
.env.production

# Snowflake connection files
*.p8
*.pem
config.toml

# Streamlit
.streamlit/secrets.toml
EOF
```

## 📝 Step 5: Add and Commit Files

```bash
# Add all files to staging
git add .

# Check what will be committed
git status

# Commit files
git commit -m "Initial commit: Customer 360 & AI Assistant demo

- Complete Snowflake-native customer analytics platform
- AI-powered customer insights and risk assessment  
- Advanced text-based search functionality
- Interactive Streamlit dashboard
- Compatible with all Snowflake editions
- Comprehensive documentation and setup scripts"
```

## 🚀 Step 6: Push to GitHub

```bash
# Push to GitHub
git push -u origin main
```

If you get an error about the branch name, try:
```bash
git branch -M main
git push -u origin main
```

## 🎨 Step 7: Add Project Assets (Optional)

### Create a Screenshots Folder
```bash
mkdir -p assets/screenshots
```

### Add a License File
```bash
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2024 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
```

## 🏷️ Step 8: Add Topics and Description

In your GitHub repository:

1. Click the ⚙️ gear icon next to "About"
2. Add description: `Snowflake-native Customer 360 & AI Assistant demo with real-time analytics and intelligent insights`
3. Add topics (tags):
   - `snowflake`
   - `customer-360`
   - `analytics`
   - `streamlit`
   - `ai-assistant`
   - `customer-insights`
   - `dashboard`
   - `data-platform`
   - `sql`
   - `python`

## 📋 Step 9: Create Additional Documentation

### Update Repository Settings
```bash
# Create a simple CONTRIBUTING.md
cat > CONTRIBUTING.md << 'EOF'
# Contributing to Customer 360 Demo

Thank you for your interest in contributing! Here are some ways you can help:

## 🐛 Bug Reports
- Use the GitHub issue tracker
- Include steps to reproduce
- Provide Snowflake edition and version

## ✨ Feature Requests  
- Describe the desired functionality
- Explain the business use case
- Consider compatibility with all Snowflake editions

## 🔧 Code Contributions
1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request

## 📖 Documentation
- Improve setup instructions
- Add more demo scenarios
- Create troubleshooting guides

## 💡 Ideas
- Start a GitHub Discussion
- Propose new analytics features
- Suggest UI improvements
EOF
```

### Create a CHANGELOG.md
```bash
cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-01-15

### Added
- Initial release of Customer 360 & AI Assistant demo
- Complete Snowflake database schema with sample data
- AI-powered customer analysis functions
- Advanced text-based search capabilities
- Interactive Streamlit dashboard
- Comprehensive documentation and setup scripts
- Compatible with all Snowflake editions

### Features
- Customer 360 profiles with risk scoring
- Document and activity search
- Customer segmentation analysis
- Real-time analytics dashboard
- Automated setup and cleanup scripts

### Documentation
- Complete README with quick start guide
- Detailed deployment guide
- Troubleshooting section
- Demo scenarios and examples
EOF
```

## 🔄 Step 10: Push Updates

```bash
# Add new files
git add .

# Commit updates
git commit -m "Add project documentation and assets

- Contributing guidelines
- Changelog
- License file
- Enhanced .gitignore
- Repository structure improvements"

# Push to GitHub
git push
```

## 🎯 Step 11: Final Repository Setup

### Enable GitHub Pages (Optional)
1. Go to repository Settings → Pages
2. Source: Deploy from a branch
3. Branch: main / (root)
4. This will create a public URL for your documentation

### Set Repository Visibility
1. Go to Settings → General → Danger Zone  
2. Choose "Change repository visibility" if needed
3. Public repositories are more discoverable

### Enable Discussions (Optional)
1. Go to Settings → General → Features
2. Check "Discussions"
3. This allows community questions and ideas

## ✅ Step 12: Verify Upload Success

1. Visit your GitHub repository URL
2. Verify all files are present:
   - ✅ README.md displays correctly
   - ✅ All SQL files in `/sql/` folder
   - ✅ Streamlit files in `/streamlit/` folder
   - ✅ Documentation in `/docs/` folder
   - ✅ Scripts in `/scripts/` folder
3. Check that code syntax highlighting works
4. Verify the repository description and topics

## 🎉 Step 13: Share Your Project

### Add to Your Profile
1. Go to your GitHub profile
2. Pin this repository (if it's one of your top projects)
3. Add it to your portfolio

### Share on Social Media
Use these hashtags:
- `#Snowflake`
- `#DataAnalytics`
- `#Customer360`
- `#AIAssistant`
- `#OpenSource`

## 🔗 Quick Commands Summary

```bash
# Complete setup in one go:
cd /path/to/your/project
git init
git remote add origin https://github.com/YOUR_USERNAME/customer-360-demo.git
git add .
git commit -m "Initial commit: Customer 360 & AI Assistant demo"
git branch -M main
git push -u origin main
```

## 🆘 Troubleshooting

### Authentication Issues
```bash
# If you have 2FA enabled, use a personal access token:
# GitHub Settings → Developer Settings → Personal Access Tokens → Tokens (classic)
# Use the token as your password when prompted
```

### Large File Issues
```bash
# If you have files over 100MB, use Git LFS:
git lfs install
git lfs track "*.zip"
git lfs track "*.csv" 
git add .gitattributes
```

### Branch Name Issues
```bash
# If your default branch is 'master' instead of 'main':
git branch -M main
git push -u origin main
```

---

**🎉 Congratulations! Your Customer 360 demo is now live on GitHub!**

Your repository should be accessible at: `https://github.com/YOUR_USERNAME/customer-360-demo` 