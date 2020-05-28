function Start-Box {
    <#
       .SYNOPSIS
       Launch Docker Containers Locally
       .DESCRIPTION
       .EXAMPLE
       Start-Box node latest
    #>
    Param (
        [parameter (Mandatory=$true)][String]$image,
        [parameter (Mandatory=$true)][String]$path,
        [string]$cmd,
        [String]$tag
    )
    Begin {
        $repo = "${image}:${tag}"
        $volume = "${HOME}\.vm\${image}"
        $box = "${image}-box"
    }
    Process {
        if((Invoke-Expression "docker ps -f name=${box} -q")) {
            Invoke-Expression "docker exec -it ${box} bash -c `"cd ${path} ; ${cmd}`""
        } else {
            if(!(Invoke-Expression "docker images -q $repo")) {
                Start-Process -Wait powershell -Verb runAs "docker pull $repo"
            }
            if(!(Test-Path $volume)) {
                New-Item -Path $volume -ItemType Directory
            }
            Invoke-Expression "docker run -it --rm --name ${box} -v ${volume}:${path} ${image} bash -c `"cd ${path} ; ${cmd}`""
        }
    }
    End {}
}
$PSDefaultParameterValues.Add("Start-Box:Cmd", "bash")
$PSDefaultParameterValues.Add("Start-Box:Tag", "latest")

# Docker Launcher Alias Commands
$go = "c:\\Users\Riggy\.vm\golang"
function go {
    Start-Box golang /go
}
function golang {
    Param ([parameter (Mandatory=$true)][String]$cmd)
    if ("${PWD}" -like "*\golang\*" -and !($cmd -like "/*")) {
        $path = ("${PWD}" -split "\\golang\\" -replace "\\","/")[1]
        Start-Box golang /go "go run ./${path}/${cmd}"
    } else {
        if($cmd -like "/*") { $cmd = ".${cmd}"}
        Start-Box golang /go "go run ${cmd}"
    }
}
$js = "c:\\Users\Riggy\.vm\node"
function js {
    Start-Box node /home/node
}
function node {
    Param ([parameter (Mandatory=$true)][String]$cmd)
    if ("${PWD}" -like "*\node\*" -and !($cmd -like "/*")) {
        $path = ("${PWD}" -split "\\node\\" -replace "\\","/")[1]
        Start-Box node /home/node "node ./${path}/${cmd}"
    } else {
        if($cmd -like "/*") { $cmd = ".${cmd}"}
        Start-Box node /home/node "node ${cmd}"
    }
}
$py = "c:\\Users\Riggy\.vm\python"
function py {
    Start-Box python /home/python
}
function python {
    Param ([parameter (Mandatory=$true)][String]$cmd)
    if ("${PWD}" -like "*\python\*" -and !($cmd -like "/*")) {
        $path = ("${PWD}" -split "\\python\\" -replace "\\","/")[1]
        Start-Box python /home/python "python ./${path}/${cmd}"
    } else {
        if($cmd -like "/*") { $cmd = ".${cmd}"}
        Start-Box python /home/python "python ${cmd}"
    }
}
function lc {
    $go
    $js
    $py
}