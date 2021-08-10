Set-StrictMode -Version Latest

function Find-LocalConfigPath {
  param (
    [Parameter(Mandatory)][String] $Dir,
    [Parameter(Mandatory)][String] $Name
  )

  while ($true) {
    if ($Dir -eq $Env:USERPROFILE -or [String]::IsNullOrEmpty($Dir)) {
      $null
      return
    }
    $test = Join-Path $Dir $Name
    if (Test-Path $test) {
      $test
      return
    }
    $Dir = Split-Path $Dir -Parent
  }
}

function Copy-HashtableDeeply {
  param (
    [Hashtable] $Hashtable
  )

  $result = @{}
  foreach ($key in $Hashtable.Keys) {
    $item = $Hashtable[$key]
    if ($item -is [Hashtable]) {
      $result.Add($key, (Copy-HashtableDeeply $item))
      continue
    }
    if ($item -is [System.ICloneable]) {
      $result.Add($key, $item.Clone())
      continue
    }
    $result.Add($key, $item)
  }
  $result
}

# right-biased.
function Join-Hashtables {
  param (
    [Hashtable[]] $Hashtables,
    [Switch] $Breaking = $false
  )

  if ($null -eq $Hashtables -or @() -eq $Hashtables) {
    $null
    return
  }

  $result = $null
  foreach ($h in $Hashtables) {
    if ($null -eq $h) {
      continue
    }
    if ($null -eq $result) {
      if ($Breaking) {
        $result = $h
      }
      else {
        $result = Copy-HashtableDeeply $h
      }
      continue
    }
    foreach ($key in $h.Keys) {
      $value = $h[$key]
      if ($result.ContainsKey($key)) {
        if ($value -is [Hashtable]) {
          if ($null -ne $result[$key]) {
            [void] (Join-Hashtables $result[$key], $value -Breaking)
          }
          else {
            $result.Remove($key)
            $result.Add($key, $h[$key])
          }
        }
        else {
          $result.Remove($key)
          $result.Add($key, $h[$key])
        }
      }
      else {
        $result.Add($key, $h[$key])
      }
    }
  }
  $result
}

# .SYNOPSIS
# Find and read configurations. This returns a joined hashtable.
#
# .PARAMETER $Name
# A name of an application.
#
# .DESCRIPTION
# When the Name parameter is “foo”, this searches configuration files that named “config.yaml” in “$Env:ProgramData\$Name”, “$Env:APPDATA\$Name”
# and “$Name.yaml” in the current working directory or its parents recursively.
function Get-Config {
  param (
    [Parameter(Mandatory)][String] $Name
  )

  $systemGlobalDataPath = "$Env:ProgramData\$Name"
  $userGlobalDataPath = "$Env:APPDATA\$Name"
  $localConfigName = "$Name.yaml"
  $globalConfigName = 'config.yaml'

  $localConfigPath = Find-LocalConfigPath (Get-Location) $localConfigName

  $configPaths = "$systemGlobalDataPath\$globalConfigName", "$userGlobalDataPath\$globalConfigName", $localConfigPath

  $configs = @()

  foreach ($path in $configPaths) {
    if ($null -ne $path -and (Test-Path $path)) {
      $configs += ConvertFrom-Yaml (Get-Content $path -Raw)
    }
  }

  Join-Hashtables $configs
}

# .SYNOPSIS
# Get an specified item in a hashtable.
#
# .PARAMETER Name
# An array of nested keys.
#
# .PARAMETER Hashtable
# A target.
function Get-HashtaleItem {
  param (
    [Parameter(Mandatory)][Object[]] $Name,
    [Hashtable] $Hashtable
  )

  $item = $Hashtable
  foreach ($n in $Name) {
    if ($null -eq $item) {
      $null
      return
    }
    $item = $item[$n]
  }
  $item
}

Export-ModuleMember -Function Get-Config, Get-HashtaleItem
