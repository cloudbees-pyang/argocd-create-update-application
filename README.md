= ARGO CD Create and Upate

== Inputs

[cols="2a,1a,1a,3a",options="header"]
.Input details
|===

| Input name
| Data type
| Required?
| Description

| `serverurl`
| String
| Yes
| argocd server url

| `user`
| String
| Yes
| user to authenticate

| `credential`
| String
| Yes
| credential to connect to server

| `projectname`
| String
| Yes
| project name

| `projectdescription`
| String
| Yes
| Project description

| `applicationname`
| String
| Yes
| application name

| `repourl`
| String
| Yes
| params to pass to build

| `targetrevision`
| String
| Yes
| params to pass to build

| `repopath`
| String
| No
| Only needed for deployment direct from git

| `destnamespace`
| String
| Yes
| Destinaton namespace

| `chartname`
| String
| No
| Helm chart is using helm

| `deploytype`
| String
| Yes
| either git or helm



|===

== Outputs

[cols="2a,1a,3a",options="header"]
.Output details
|===

| Output name
| Data type
| Description



|===


== Usage example

In your YAML file, add:

[source,yaml]
----
      - uses: guru-actions/argocd-create-update-project@0.25
        name: deploy_argocd
        with:
          serverurl: ${{ vars.argocd_guru_url }}
          user: ${{ vars.argocd_guru_user }}
          credential: ${{ secrets.argocd_guru_cred }} 
          projectname: "default"
          projectdescription: "created via the cloudbeed platform"
          applicationname: "tawny-prod"
          repourl: "https://nexus.guru-rep.sa-demo.beescloud.com/repository/helm-hosted/"
          targetrevision: "$BUILD_ID"
          destnamespace: "tawny-prod"
          chartname: "tawny"
          deploytype: "helm"

----

