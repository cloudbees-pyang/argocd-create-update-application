#!/bin/bash
ARGOCD_SERVER="http://argocd.guru-rep.sa-demo.beescloud.com" # note we follow symlinks

# Set ArgoCD username and password
USERNAME="admin"
PASSWORD="***" # note, we dont need to use token
CREATE_PROJECT="false" # we can check if project exists first
SOURCE_TYPE="git" # can be git or helm
# Set the project name and description
PROJECT_NAME="default" # project name, not the app name !
PROJECT_DESCRIPTION="This is an example ArgoCD project."
APP_NAME="demo-app2" # app name, not to be confused with project
REPO_URL="https://github.com/stubrowncloudbees/argotest.git" #either nexus url or git rpo url
TARGET_REVISION="test456" #either branch or helm version

# Set the destination namespace
DEST_NAMESPACE="demo-app" #needed for git and helm

# Set the path within the Git repository
REPO_PATH="demo-app" # needed for git only
HELM_CHART="statusapp" #needed for helm only 








create_application() {
  dtype=$1
  aname=$2
  trev=$3
  rurl=$4
  pname=$5
  destns=$6
  spath=$7 #only needed for git



#for GIT
 PAYLOADGIT=$(cat <<EOF
{
  "metadata": {
    "name": "$aname"
  
  },
  "spec": {
    "source": {
      "repoURL": "$rurl",
      "path": "$spath",
      "targetRevision": "$trev"
    },
    "destination": {
      "server": "https://kubernetes.default.svc",
      "namespace": "$destns"
    },
    "project": "$pname",
    "syncPolicy": {
      "automated": {
        "prune": true,
        "selfHeal": true
      }
    }
  }
}
EOF
)

#for helm
 PAYLOADHELM=$(cat <<EOF
{
  "metadata": {
    "name": "$aname"
  },
  "spec": {
    "source": {
      "repoURL": "$rurl",
      "targetRevision": "$trev",
      "chart": "$spath"
    },
    "destination": {
      "server": "https://kubernetes.default.svc",
      "namespace": "$destns"
    },
    "project": "$pname",
    "syncPolicy": {
      "automated": {
        "prune": true,
        "selfHeal": true
      }
    }
  }
}
EOF
)
  if [[ $dtype == "git" ]]; then
    PAYLOAD=$PAYLOADGIT
  elif [[ $dtype == "helm" ]]; then
    PAYLOAD=$PAYLOADHELM
  else
    echo "unknown type"
  fi

  SESSION_TOKEN=$(curl -s -L -k -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}" -H "Content-Type: application/json" "$ARGOCD_SERVER/api/v1/session" | jq -r .token)

  # Create the ArgoCD application
  response=$(curl -s -o response.txt -w "%{response_code}" -k -L -X POST -H "Content-Type: application/json" --data "$PAYLOAD" "$ARGOCD_SERVER/api/v1/applications?upsert=true/" --cookie "argocd.token=$SESSION_TOKEN")
  #cat response.txt |jq .metadata.managedFields[0].operation
  cat response.txt
  if [[ $response -eq 200 ]]; then
    echo "complete"
    
  else
    echo "Error: Unexpected HTTP status code $response."
  fi

}



function check_proj_exists () {
  pname=$1
  #echo "connecting to $ARGOCD_SERVER"  >&2
  # Make the API call to check if the project exists
  SESSION_TOKEN=$(curl -s -L -k -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}" -H "Content-Type: application/json" "$ARGOCD_SERVER/api/v1/session" | jq -r .token)
  #curl  -L -k -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}" -H "Content-Type: application/json" "$ARGOCD_SERVER/api/v1/session" 
  #echo "session token - $SESSION_TOKEN"  >&2
  # Check if project exists
  #curl -s -k  -L  "$ARGOCD_SERVER/api/v1/projects/$PROJECT_NAME" --cookie "argocd.token=$SESSION_TOKEN"
  response=$(curl -s -k -L  -o /dev/null -w "%{http_code}" "$ARGOCD_SERVER/api/v1/projects/$pname" --cookie "argocd.token=$SESSION_TOKEN")
  

  if [[ $response -eq 200 ]]; then
    #echo "Project $PROJECT_NAME exists."
    echo "exists"
  elif [[ $response -eq 404 ]]; then
    echo "Project $PROJECT_NAME does not exist."
  else
    echo "Error: Unexpected HTTP status code $response."
  fi
  


}

function check_application_exists () {
  aname=$1
  #echo "connecting to $ARGOCD_SERVER"  >&2
  # Make the API call to check if the project exists
  SESSION_TOKEN=$(curl -s -L -k -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}" -H "Content-Type: application/json" "$ARGOCD_SERVER/api/v1/session" | jq -r .token)
  #curl  -L -k -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}" -H "Content-Type: application/json" "$ARGOCD_SERVER/api/v1/session" 
  #echo "session token - $SESSION_TOKEN"  >&2
  # Check if project exists
  #curl -s -k  -L  "$ARGOCD_SERVER/api/v1/projects/$PROJECT_NAME" --cookie "argocd.token=$SESSION_TOKEN"
  response=$(curl -s -k -L  -o /dev/null -w "%{http_code}" "$ARGOCD_SERVER/api/v1/applications/$aname" --cookie "argocd.token=$SESSION_TOKEN")
  

  if [[ $response -eq 200 ]]; then
    echo "exists"
  elif [[ $response -eq 404 ]]; then
    echo "application $aname does not exist."
  else
    echo "Error: Unexpected HTTP status code $response."
  fi
  


}




if [[  $(check_proj_exists "$PROJECT_NAME") == "exists" ]]; then

  echo "project does exists"
else
  echo "project doesnt exists"  
  if [[  "$CREATE_PROJECT" == "true" ]]; then 
    echo "going to create project"
  else
    echo "not creating project"
    exit

  fi

fi

if [[  $(check_application_exists "$APP_NAME") == "exists" ]]; then
  echo "application does exists"
else
 echo "application doesnt exists"
fi


  # aname=$1
  # trev=$2
  # rurl=$3
  # pname=$4
  # destns=$5
  # spath=$6 # path for git, chart for helm

# for git 
#create_application "git" "stu2803280756a" "test123" "https://github.com/stubrowncloudbees/argotest.git" "default" "demoapp" "demo-app"

# for helm
create_application "helm" "stu2803280756c" "0.0.45" "https://nexus.guru-rep.sa-demo.beescloud.com/repository/helm-hosted/" "default" "demo-app" "statusapp"