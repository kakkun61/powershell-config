# Call Invoke-Pester

Set-StrictMode -Version Latest

Import-Module powershell-yaml

Describe "Get-Config" {
  It "local config" {
    $expected = @{
      foo = 'bar'
    }
    ConvertTo-Yaml $expected | Out-File "$name.yaml"
    $actual = Get-Config $name
    $actual.Keys | Should -Be $expected.Keys
    $actual.foo | Should -Be $expected.foo
  }

  It "local config (int)" {
    $expected = @{
      foo = 1
    }
    ConvertTo-Yaml $expected | Out-File "$name.yaml"
    $actual = Get-Config $name
    $actual.Keys | Should -Be $expected.Keys
    $actual.foo | Should -Be $expected.foo
  }

  It "user global config" {
    $expected = @{
      foo = 'bar'
    }
    ConvertTo-Yaml $expected | Out-File "$Env:APPDATA\$name\config.yaml"
    $actual = Get-Config $name
    $actual.Keys | Should -Be $expected.Keys
    $actual.foo | Should -Be $expected.foo
  }

  It "system global config" {
    $expected = @{
      foo = 'bar'
    }
    ConvertTo-Yaml $expected | Out-File "$Env:ProgramData\$name\config.yaml"
    $actual = Get-Config $name
    $actual.Keys | Should -Be $expected.Keys
    $actual.foo | Should -Be $expected.foo
  }

  It "joined config" {
    $local = @{
      bar = 'bar'
    }
    $user = @{
      bar = 'bazz'
    }
    $system = @{
      foo = 'foo'
    }
    $expected = @{
      foo = 'foo'
      bar = 'bar'
    }
    ConvertTo-Yaml $local | Out-File "$name.yaml"
    ConvertTo-Yaml $user | Out-File "$Env:APPDATA\$name\config.yaml"
    ConvertTo-Yaml $system | Out-File "$Env:ProgramData\$name\config.yaml"
    $actual = Get-Config $name
    $actual.Keys.Length | Should -Be $expected.Keys.Length
    $actual.foo | Should -Be $expected.foo
    $actual.bar | Should -Be $expected.bar
  }

  BeforeAll {
    New-Variable -Option Constant, AllScope -Name name -Value 'powershell-config'

    New-Variable originalProgramData -Option Constant -Value "$Env:ProgramData"
    New-Variable originalAPPDATA -Option Constant -Value "$Env:APPDATA"
    New-Variable originalPWD -Option Constant -Value "$PWD"

    function New-TemporaryDirectory {
      $parent = [System.IO.Path]::GetTempPath()
      [String] $temp = New-Guid
      New-Item -ItemType Directory -Path (Join-Path $parent $temp)
    }

    $Env:ProgramData = New-TemporaryDirectory
    New-Item -ItemType Directory -Path "$Env:ProgramData\$name"

    $Env:APPDATA = New-TemporaryDirectory
    New-Item -ItemType Directory -Path "$Env:APPDATA\$name"

    Import-Module -Force (Join-Path "$PSScriptRoot" 'config.psm1')

    $tempPWD = New-TemporaryDirectory
    Set-Location $tempPWD
  }

  AfterAll {
    Remove-Item $Env:ProgramData -Recurse -ErrorAction Ignore
    Set-Location $originalPWD
    Remove-Item $tempPWD -Recurse
    Set-Item Env:\ProgramData -Value $originalProgramData
    Set-Item Env:\APPDATA -Value $originalAPPDATA
  }

  AfterEach {
    Remove-Item "$name.yaml", "$Env:APPDATA\$name\config.yaml", "$Env:ProgramData\$name\config.yaml" -ErrorAction Ignore
  }
}
