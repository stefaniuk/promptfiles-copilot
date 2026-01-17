---
agent: agent
description: Produce AWS infrastructure diagram from Terraform (evidence-first, consistent with C4 container naming)
---

**Mandatory preparation:** read [codebase overview](../instructions/includes/codebase-overview-baseline.include.md) instructions in full and follow strictly its rules before executing any step below.

## Goal

Create (or update) the [AWS infrastructure page](../../docs/codebase-overview/aws-infrastructure.md) and [AWS infrastructure diagram](../../docs/codebase-overview/aws-infrastructure.drawio), then export the diagram to PNG once complete.

Also ensure this work is linked from: [codebase overview](../../docs/codebase-overview/README.md) output.

Constraints:

- Derive every element from Terraform/IaC code (no speculation)
- Use AWS architecture styling, icons, and colour palette as provided by the official AWS icon set packaged in Draw.io
- Keep diagram layers/groups consistent (e.g. networking, compute, data stores)
- Label AWS accounts/regions when known
- Keep names consistent with the C4 Container diagram where possible (service/container names), without inventing mappings

---

## Discovery (run before writing)

### A. Terraform/IaC reconnaissance

1. Enumerate Terraform roots (directories with `main.tf`, `terragrunt.hcl`, or `*.tf.json`). Classify them by environment (prod/stage/dev) if evident.
2. Identify supporting IaC: Terraform modules, Terragrunt stacks, Terraform Cloud/Backend config, helpers (Makefiles, wrapper scripts).
3. Record backend/storage configuration (S3/DynamoDB/remote backend) for state handling.

### B. Resource classification (evidence mandatory)

For each Terraform root/module:

1. List AWS providers and aliases in use.
2. Capture declared resources/data sources grouped by capability:
   - Network & security (VPC, subnets, routing, security groups, Network ACLs, Load Balancers, API Gateway, WAF)
   - Compute & container (EC2, ASG, ECS, EKS, Lambda, Batch)
   - Data & storage (RDS, Aurora, DynamoDB, S3, ElastiCache, OpenSearch)
   - Integration & messaging (SQS, SNS, EventBridge, Kinesis, Step Functions)
   - Identity & access (IAM roles/policies, Cognito, Secrets Manager, KMS)
   - Tooling/observability (CloudWatch, X-Ray, SSM, Code\* services)
3. Note explicit dependencies (e.g. `depends_on`, module outputs, data source references) that define relationships between resources.
4. Mark any resource whose purpose is unclear as **Unknown from code – confirm usage**.

### C. Environment overlays

1. Determine whether Terraform code parameterises environments (workspaces, `var.env`, Terragrunt inputs).
2. Capture per-environment differences that affect topology (resource counts, regions, scaling parameters).
3. Identify shared infrastructure vs environment-specific stacks.

---

## Steps

### 1) Build the infrastructure inventory

1. Create a tabular summary (working notes) of every AWS service present, including:
   - Resource name/id pattern
   - Module/source file path
   - Environment/region/account (if available)
   - Key tags (Name, Service, Owner) if defined
2. Highlight critical ingress/egress points:
   - Public entry (ALB/NLB/API Gateway/CloudFront)
   - Private entry (VPN, Transit Gateway, Direct Connect)
   - Outbound integrations (third-party APIs, SaaS endpoints)
3. Identify data-flow paths (client → edge → compute → data store) based on resource references and outputs.
4. Capture resilience topology where evidenced (multi-AZ, autoscaling, failover, backups).

### 2) Define diagram layers and grouping rules

1. Use AWS architecture best practices:
   - Group resources inside VPC/availability-zone containers
   - Separate networking, compute, data, and shared services layers
   - Annotate security boundaries (public subnet, private subnet, on-prem, third-party)
2. Create a legend or note in Draw.io describing colour/icon conventions (only once per diagram if space permits).
3. Keep labels concise and derivable from Terraform (module names, `var.service_name`, `tags["Name"]`).

### 3) Create or update draw.io diagram

1. Open `aws-infrastructure.drawio`.
2. Reproduce the infrastructure based on Terraform evidence:
   - Place AWS icons for each major resource (ALB, ECS Service, RDS, etc.)
   - Connect components to show traffic/data direction (ingress → compute → data)
   - Annotate connections with protocols/ports if Terraform security groups or listeners provide that info
3. Use Draw.io layers or groups to represent environments if multiple share the same page; otherwise create duplicate pages per environment.
4. Record unresolved items in a dedicated **Unknown from code** sticky note inside the diagram (non-exporting layer) to maintain transparency.
5. Where you can map an AWS "compute" resource to a deployable unit in the repo (from `repository-map.md` / C4 container diagram), label it accordingly and include a short evidence pointer. If you cannot map it, keep the label Terraform-derived and record **Unknown from code – map resource to deployable**.

### 4) Document evidence and outputs

1. Update [codebase overview](../../docs/codebase-overview/README.md) with:
   - Link to the draw.io file (and PNG/SVG if exported)
   - Short summary of what the diagram covers (environments, date of last refresh)
   - Instructions to regenerate (e.g. "Open in draw.io desktop/web and refresh AWS icons from Terraform module XYZ")
2. Add an **Evidence** section to `aws-infrastructure.md`, referencing Terraform files for each major diagram element.
3. If automation or scripts exist for exporting diagrams, document usage (command, output path) or record **Unknown from code – locate diagram export tooling**.

---

## Diagram style requirements

- Use the official AWS 2024 icon set within Draw.io (available via _Arrange → Insert → Advanced → AWS Architecture_ if not already loaded).
- Maintain consistent sizing and spacing; align elements using Draw.io guides.
- Label subnets, route tables, and security zones directly on the canvas.
- Use muted background colours for groups (VPC, AZ) to keep icons readable.
- For external systems or SaaS providers not in AWS, use generic grey boxes with clear labels.

### Mandatory naming and labelling conventions

Every infrastructure diagram must follow these naming rules verbatim (update existing elements if they drift):

1. **Resource nodes:** Use lowercase kebab-case `{service}-{role}-{scope}`, e.g. `alb-public-edge`, `ecs-task-api`, `rds-primary-app`. Names must map to Terraform modules, resource blocks, or tags so reviewers can trace them back.
2. **Environment overlays:** Prefix or suffix with the environment name when multiple environments appear on the same page, e.g. `vpc-app-prod`, `ecs-service-orders-stg`.
3. **Subnet and security groups:** Name subnets and zones as `{visibility}-subnet-{az}` (`public-subnet-a`, `private-subnet-b`) and security zones as `{zone}-security-zone`.
4. **Accounts and regions:** Label AWS accounts with friendly name plus account ID (`acct-core (123456789012)`) and regions as `region-<code>` (`region-eu-west-2`). Place these labels on grouping containers.
5. **Arrow titles:** Label every arrow with `{protocol}/{port}` or `{action}` (e.g. `HTTPS/443`, `Publish events`, `Read replicas`). If both apply, prefer `HTTPS/443 – public ingress`.
6. **Legend:** Include a small legend per diagram page describing arrow colours, border styles, and environment colouring (e.g. "orange arrows = ingress traffic", "blue arrows = data writes").
7. **Unknowns:** Any placeholder or dotted element must be suffixed with `-pending` and accompanied by an **Unknown from code** sticky note referencing the missing evidence.

---

## Quality gates

1. Validate the Draw.io file opens without errors (use the Draw.io desktop/web validator) and retains AWS icon library references.
2. If a PNG/SVG export is stored, ensure it updates after modifications.
3. Confirm Terraform formatting via `terraform fmt -check` in any touched directories when the prompt automation makes code changes (if part of its workflow).
4. Ensure README links render correctly in Markdown (relative paths).

---

## Evidence and unknowns (mandatory)

For every logical cluster (networking, compute, data, integration):

- Provide at least one evidence bullet referencing the Terraform file(s) and resource names.
- If Terraform only defines part of a dependency (e.g. IAM role without the consuming service), record **Unknown from code – confirm {dependency}**.

---

## Output format

Example evidence snippet:

```markdown
### AWS Infrastructure

## Diagram

{PNG file}

{link to draw.io file}

{summary}

## Evidence

- Evidence: [path/to/file](/path/to/file#L20-L58) - {symbol or config key}
- Evidence: Unknown from code – {suggested action}
```

---

> **Version**: 1.1.2
> **Last Amended**: 2026-01-17
