# **GitHub Copilot Agent Mode & MCP Demo**

This demo app can be used to show a number of Copilot features:

- **Agent Mode and Vision**: generate a fairly complex UI updated (add the Cart functionality to the site) all with a natural language prompt and an image
- **Unit Testing**: run and generate unit tests to improve coverage
- **MCP Server**: 
  - generate a `.feature` file (Behaviour Driven Development/Tesing file)and use Playwright to launch a browser and test the scenario
  - Interact with GitHub via the GitHub MCP server
- **Custom instructions**: personalize how Copilot responds by pointing to a fictional private observability framework that Copilot can work with, even though it is not a public library
- **Security**: 
  - Enable GHAS scans on the repo, and after finding a vulnerability, generate an autofix
  - Ask GitHub to find vulnerabilities in the code, then explain and fix them
- **Actions**: generate Actions workflows for deploy/publish
- **Infrastructure as Code**: generate Bicep or Terraform files for publishing
- **Padawan (SWE Agent)**: You can also ask Copilot to code via Padawan for some of the above scenarios by logging issues and assigning them to Copilot

### **Setting Up the Demo**
- **What to show:** A TypeScript API and Frontend (React) project that you will enhance with Copilot Agent Mode and Vision.
- **Why:** Demonstrate how Copilot can analyze and enhance existing code automatically, understand images, vulnerabilities and testing and how you can extend Copilot's capabilities with MCP server.
- **MCP Servers**: The GitHub MCP server runs via Docker. You will need to install Docker locally to run it (it should work fine in a Codespace automatically). I use Podman for my Mac. Install this _before_ you attempt this demo! You'll also need a PAT that has enough permissions for your demos. Details below.
- **Local vs Codespaces:**  
  - This demo can work in a Codespace - but some scenarios (like running Playwright tests) require that you work in a local VSCode (clone the repo locally)
  - Make sure you **PRACTICE** this demo _before_ trying it in front of customers
  - Remember, Copilot is non-deterministic so you can't always predict exact behavior. Make sure you are comfortable with this environment so you can pivot quicky!
  - You don't have to use **VS Code Insiders** Version unless you want to demo features that you know are in preview.
    - If you want to access the Insiders Version in the web-version of a Codespace, click on the gear-icon on the bottom-left and select `Switch to Insiders Version...`

  ![Switch to Insiders](./vscode-switch-to-insiders.png)

### **Building, Running and Debugging the code**

There is a detailed overview of the arcitecture [here](./architecture.md). Make sure to familiarize yourself with the architecture.

To build the application, you need to run `npm install && npm build` in both the [API](../api/) folder and the [Frontend](../frontend/) folder. Then you can run `npm run start:install` in the API folder to run both the API and the frontend together.

There are also task definitions and launch profiles:
- **Build**: Hit `Cmd/Ctrl + Shift + P -> Run Task -> Build All`
- **Run/debug**: Click on the Debug panel, select the `Start API & Frontend` target and click start

### **MCP Server install and config**

If you are wanting to show MCP server integration, you will need to set up and configure the MCP servers _prior_ to the demo. I have included the necessary `mcp` config in the [devcontainer.json](../.devcontainer/devcontainer.json) file, but you may have to copy/paste this to your user config if you are running this locally and not in a Codespace. You will need a PAT for the GitHub MCP server.

#### Start the Playwright MCP Server
- Use the cmd palette `Cmd/Ctrl + Shift + P` -> `MCP: List servers` -> `playwright` -> `Start server`

##### Start the GitHub MCP Server
- This server runs via Docker image, so you will need Docker to be installed and running before starting this server. I use Podman on my Mac.
- Use the cmd palette `Cmd/Ctrl + Shift + P` -> `MCP: List servers` -> `github` -> `Start server`. The first time you run this, you will have to supply a PAT.

> Generate a fine-grained PAT that has permissions to read/write Issues and PRs, context and whatever other features you want to demo. You can create this at the org/repo level. I suggest creating a PAT and storing it in a key vault (or 1Password) so that you have it handy.

### **Demo 1: Using Vision and Agent to Generate Cart Functionality**  
- **What to show:** "Vibe coding" using Agent Mode and Vision to complete complex tasks.
- **Why:** Demonstrate how Copilot Vision can detect design and how Agent can understand a codebase and create complex changes over multiple files.
- **How:**  
  1. Run the App to show the original code. Once the site starts, click on "Products" in the NavBar and show the Product Page. Add an item to the Cart - note that nothing actually happens, except a message saying, "Added to Cart". Explain that there is no Cart in the frontend app currently.
  1. Open Copilot and switch to "Ask" mode. Select `Claude 3.7 Sonnet Thinking` to demonstrate a thinking/planning phase and model selector.
  1. Attach the [cart image](../docs/design/cart.png) using the paperclip icon or drag/drop to add it to the chat.
  1. Enter the following prompt:
    ```txt
    First, look at the Cart design and the code for the Frontend app. Plan what changes you will need to implement to create the a Cart Page. I also want a Cart icon in the NavBar that shows the number of items in the Cart. Ignore the discount shown on the image. Do not change and code.
    ```
  1. Highlight that Copilot has suggested changes and planned the components to add/modify.
  1. Switch to "Agent" mode in Copilot Chat. Switch to `Claude 3.5 Sonnet` (a good implementation model) and enter this prompt:
    ```txt
    Implement the changes.
    ```
  1. Show Copilot's changes and how you can see each one and Keep/reject each one.
  1. Accept Copilot’s suggested fixes.
  1. Go back to the Frontend app. Navigate to Products. Show adding items to the cart (note the icon updating). Click on the Cart icon to navigate to the Cart page. Show the total, and adding/removing items from the cart.

### **Demo 2: MCP Servers**  
- **What to show:** Launch browser navigation using Playwright MPC server to show functional testing from natural language. Show integration to GitHub via the GitHub MCP server.
- **Why:** Demonstrate support for extending Copilot capabilities using MCP server protocol.
- **How:**  
  1. Ask Copilot to `add name and description properties to all entities`.
  1. Show how it modifies multiple files simultaneously.
  1. Accept the changes.

### **Step 4: Running Terminal Commands & Generating Swagger API Docs**  
- **What to show:** Using Copilot Agent Mode to add Swagger packages and config.
- **Why:** Demonstrate how Copilot can execute commands as part of its flow.
- **How:**  
  1. Ask Copilot to `install Swagger packages and configure API docs for the supplier entity`  
  1. Show how Copilot:  
     - Suggests a command and waits for confirmation.
     - Executes it in the terminal.
     - Updates `index.ts` with Swagger config and generates API docs.
  1. You might need to explicitly ask for the JSON schema defnition of the Supplier entity: `Add the swagger schema definition for the Supplier entity`. 
  1. Run `npm dev`, open `localhost:3000/api/docs`, and show the Swagger UI.
  1. Click on the `/get` route and execute, showing returning of an emtpy array `[]`

### **Step 5: Fixing API Route Issues (only if the above step fails when retrieving the list of entities)**
- **What to show:** Copilot fixing an incorrect API route (`/api/api`).
- **Why:** Demonstrate Copilot’s ability to debug and correct issues in real time.
- **How:**  
  1. Run an API request and show the incorrect `/api/api` route.
  1. Ask Copilot to `fix the Swagger route configuration to remove duplicate /api/api`.
  1. Accept the fix, restart the app, and verify the correct behavior in the Swagger UI.

### **Step 6: Automating Deployment with Docker & GitHub Actions**  
- **What to show:** Copilot generating a Dockerfile and CI/CD workflow.
- **Why:** Show Copilot’s ability to automate deployment setup.
- **How:**  
  1. Ask Copilot to `Create a Dockerfile for an Alpine container add a GitHub Actions workflow for building the container. Use the GitHub package registry to publish the container.`
  2. Show generated files:  
     - `Dockerfile` with correct settings.
     - `.dockerignore` for clean builds.
     - GitHub Actions YAML to build & push the image to GHCR.
  3. Accept the changes.
  4. Commit and push to see the pipeline execution 

### **Step 7: Agent Mode Test Generation**  
- **What to show:** Copilot generating a multiple tests, exucuting them and self-healing.
- **Why:** Show Copilot’s ability to quickly and easily generate tests and validate.
- **How:**  
  1. Ask Copilot to `ensure all entities and routes are tested`
  2. Show generated files tests.
  3. Show Copilot "self-healing" (if tests fail)
  3. Accept the changes.

### **Step 8: Custom instructions**
- **What to show:** Copilot’s **Custom instructions** feature.
- **Why:** Demonstrate that Copilot can be customized and personalized, including internal libraries that do not exist in the foundational models.
- **How:**  
  1. Delete the Supplier route file [src/routes/supplier.ts](src/routes/supplier.ts) if it exists
  1. Create an empty file: `.github/copilot-instructions.md`
  1. Enter the following content:
    ```markdown
    # Guidelines for REST APIs
    
    For REST APIs, use the following guidelines:
    
    * Use descriptive naming
    * Add Swagger docs for all API methods
    * Implement logging and monitoring using [TAO](../docs/tao.md)
      - assume TAO is installed and never add the package
    ```
  1. Mention how there are best practices as well as a doc reference to the TAO framework (a fictional library). Open the [TAO](./tao.md) doc to show the library.
  1. Ask Copilot: `Add the Supplier route`.
  1. Show the changes - note that _this will not compile_ since TAO doesn't really exist!
  
### **Step 9: Next Edit Suggestions for Refactoring Code**  
- **What to show:** Copilot’s **Next Edit Suggestions** feature.
- **Why:** Demonstrate that Copilot can anticipate your next actions.
- **How:**  
  1. Create a `point.ts` file with a `Point` class.
  1. Fill out the code using Code Completion till you have some properties and methods.
  1. Change `class Point` to `class Point3D` and let **Next Edit Suggestions** take over.
  1. Show how **Next Edit Suggestions** proposes changes step by step.
  1. Accept changes incrementally by pressing **Tab** until completion.

## **Key Takeaways for Customers**  
- **Agent Mode handles multi-step changes across multiple files** — saving time.
- **Vision enables Copilot to understand images and auto-generate missing parts.**  
- **Command execution allows Copilot to install dependencies and configure projects.**  
- **Next Edit Suggestions streamlines work.**
