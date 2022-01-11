
# Binaries
set --export PATH $PATH ~/.local/bin

# General
function http --description 'httpie in a docker container'
  docker run -t --rm -v /var/run/docker.sock:/var/run/docker.sock --log-driver none --net host --name httpie jess/httpie $argv
end

# Terminal
starship init fish | source

# Kubernetes
alias kc='kubectl'

function pod_cons --description 'List all containers for pods' --argument-names env
  kubectl get pods -n $env -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' | sort
end

function podname --argument-names env name
    kubectl -n $env get pods | grep $name | awk '{print $1}' | head -n 1;
end

# Git
function gpall --description 'git pull all subdirectories'
  find . -mindepth 1 -maxdepth 1 -type d -print -exec git -C $PWD/'{}' pull \; -exec echo -e "" \;
end
