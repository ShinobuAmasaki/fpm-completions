$OptionsWithArgFpm = @(
   '--archiver',
   '--compiler',
   '--flag',
   '--c-compiler',
   '--c-flag',
   '--cxx-compiler',
   '--cxx-flag',
   '--link-flag',
   '--profile',
   '--prefix',
   '--runner',
   '--runner-args',
   '--target',
   '--bindir',
   '--includedir',
   '--libdir',
   '--testdir',
   '--dump',
   '--registry-cache',
   '--token',
   '--'
)
# $OptionsNoArgFpm = @(
#    '--clean',
#    '--dry-run',
#    '--version',
#    '--help',
#    '--verbose',
#    '--all',
#    '--skip',
#    '--app',
#    '--backfill',
#    '--bare',
#    '--example',
#    '--full',
#    '--src',
#    '--lib',
#    '--test',
#    '--tests',
#    '--list',
#    '--no-prune',
#    '--no-rebuild',
#    '--dump',
#    '--show-model',
#    '--show-package-version',
#    '--show-upload-data'
# )

function AvailableCommands {
   param (
      [String[]]$Commands
   )
   $available = $Commands | Where-Object {
      try {
         Get-Command $_ -ErrorAction Stop
      }
      catch { $null }
   }
   return $available
}

function FindManifestFpm {
   param (
      [string]$StartPath = (Get-Location)
   )

   $rootpath = $StartPath
   while ($rootpath -ne [System.IO.Path]::GetPathRoot($rootpath)) {
      if (Test-Path (Join-Path $rootpath "fpm.toml")) {
         return $rootpath
      }
      $rootpath = Split-Path $rootpath -Parent
   }
   # Write-Host "Not Found"
   return $null
   
}


function DoesOptionTakeArgFpm {
   param (
      [string]$flag
   )
   return ($flag -in $OptionsWithArgFpm)
   
}
function GetOptionsFpm {
   param([string]$Subcmd,
         [System.Management.Automation.Language.CommandAst]$Ast
        )

   $tokens = @($commandAst.CommandElements | ForEach-Object { $_.Value })

   $cleanOptions = @("--all", "--skip")

   $newOptions = @(
      "--app",
      "--backfill",
      "--bare",
      "--example",
      "--full",
      "--lib",
      "--src",
      "--test"
   )
   $buildOptions = @(
      "--archiver",
      "--compiler",
      "--flag",
      "--c-compiler",
      "--c-flag",
      "--cxx-compiler",
      "--cxx-flag",
      "--help",
      "--link-flag",
      "--list",
      "--no-prune",
      "--profile",
      "--show-model"
      "--target",
      "--tests",
      "--dump"
      "--version"
   )

   $runOptions = @(
      "--all",
      "--archiver",
      "--compiler",
      "--flag",
      "--c-compiler",
      "--c-flag",
      "--cxx-compiler",
      "--cxx-flag",
      "--help",
      "--link-flag",
      "--list",
      "--",
      "--profile",
      "--runner",
      "--runner-args",
      "--target"
   )
   $testOptions = @(
      "--archiver",
      "--c-compiler",
      "--c-flag",
      "--compiler",
      "--cxx-compiler",
      "--cxx-flag",
      "--flag",
      "--help",
      "--list",
      "--",
      "--profile",
      "--runner",
      "--runner-args",
      "--target"
   )

   $installOptions =@(
      "--bindir",
      "--c-flag",
      "--cxx-flag",
      "--flag",
      "--includedir",
      "--libdir",
      "--link-flag",
      "--no-prone",
      "--no-rebuild",
      "--prefix",
      "--profile",
      "--test",
      "--testdir",
      "--verbose"
   )

   # $publishOptions = @(
   #    "--show-package-version",
   #    "--show-upload-data",
   #    "--dry-run",
   #    "--help",
   #    "--version",
   #    "--verbose",
   #    "--token"
   # )

   $updateOptions = @(
      "--fetch-only",
      "--clean",
      "--verbose",
      "--dump"
   )

   $listOptions = @(
      "--list",
      "--version",
      "--help"
   )

   switch ($Subcmd) {
      'new' {return @( $newOptions | Where-Object {$_ -notin $tokens})}
      'build' {return @( $buildOptions | Where-Object {$_ -notin $tokens})}
      'run' {return @( $runOptions | Where-Object {$_ -notin $tokens})}
      'test' {return @( $testOptions | Where-Object {$_ -notin $tokens})}
      'install' {return @( $installOptions |  Where-Object{$_ -notin $tokens})}
      # 'publish' {return @($publishOptions | Where-Object {$_ -notin $tokens})}
      'update' {return @($updateOptions | Where-Object {$_ -notin $tokens})}
      'list' {return @($listOptions | Where-Object {$_ -notin $tokens})}
      'clean' {return @( $cleanOptions | Where-Object {$_ -notin $tokens})}
      Default {return $null}
   }

}

$fpmCompletions = {
   param($wordToComplete, $commandAst, $cursorPosition);

   $fpmCommands = @("fpm", "fpm.exe", "fpm-*")

   # Subcommands
   $subCmdNoArg = @("clean", "install", "publish", "list", "manual", "update")
   $subCmdWithArg = @("build", "help", "new", "run", "test", "list")

   $subCmd = @($subCmdNoArg + $subCmdWithArg)
   $helpCommands = @($subCmd + "runner", "version", "fpm")

   # Options' arguments
   $FC = @("gfortran", "ifort", "ifx", "flang")
   $CC = @("cl", "gcc", "icx", "clang")
   $CXX = @("cl", "g++", "icx", "clang++")
   $AR = @("ar", "lib")
   $PROF = @("release", "debug")

   $runners = @("cafrun", "mpiexec", "mpirun", "gdb", "varglind")

   $tokens = @($commandAst.CommandElements | ForEach-Object { $_.Value })
   $prevToken = $tokens[-2]
   $currToken = $tokens[-1]

   if ($tokens.Count -ge 2) {
      $sub = $tokens[1]
   } else {
      $sub = ""
   }
   $projectRoot = FindManifestFpm

   ### For debug
   # Write-Host "L250:"
   # Write-Host "L251: count:     "$tokens.Count
   # Write-Host "L252: sub-cmd:   '$sub'"
   # Write-Host "L253: prevToken: '$prevToken'"
   # Write-Host "L254: currToken: '$currToken'"
   # Write-Host "L255: project:   '$projectRoot'" 
   
   $condLast = (DoesOptionTakeArgFpm -flag $prevToken)
   $condCurr = (DoesOptionTakeArgFpm -flag $currToken)
   if ($condLast -or $condCurr) {

      $long = if ($currToken -in $OptionsWithArgFpm) {
         $currToken
      } elseif ($prevToken -in $OptionsWithArgFpm) {
         $prevToken
      } else {
         $null
      }

      switch ($long) {
         "--compiler" { $candidateItems = @( (AvailableCommands -Commands $FC) | Where-Object {$_ -like "$wordToComplete*"}) }
         '--flag' {$candidateItems = @('"')}
         '--c-compiler' { $candidateItems = @((AvailableCommands -Commands $CC)| Where-Object {$_ -like "$wordToComplete*"})}
         '--c-flag' {$candidateItems = '"'}
         '--cxx-compiler' { $candidateItems = @( (AvailableCommands -Commands $CXX) | Where-Object {$_ -like "$wordToComplete*"})}
         '--cxx-flag' {$candidateItems = '"'}
         '--profile' { $candidateItems = @( $PROF | Where-Object {$_ -like "$wordToComplete*"})}
         '--runner' { $candidateItems = @( (AvailableCommands -Commands $runners) | Where-Object {$_ -like "$wordToComplete*"} )}
         '--linker-flag' {$candidateItems = '"'}
         '--archiver' { $candidateItems = @((AvailableCommands -Commands $AR) | Where-Object {$_ -like "$wordToComplete*"})}
         '--runner-args' {$candidateItems = '" '}
         '--bindir' {}
         '--includedir' {}
         '--libdir' {}
         '--' {}
         default {return $null}
      }

   } else {

      if ($sub -in $subCmdWithArg) {
         ## COMMANDs take some arguments: build, run, test, new
         if (($sub -eq "build") -or ($sub -eq 'run')) {
            $exeFiles = @(Get-ChildItem -Path (Join-Path $projectRoot build) -Recurse -Filter "*.exe" | 
               Where-Object { $_.FullName -match '\\app\\' } |
               ForEach-Object { $_.BaseName } |
               Sort-Object -Unique)
         } elseif ($sub -eq 'test') {
            $exeFiles = @(Get-ChildItem -Path (Join-Path $projectRoot build) -Recurse -Filter "*.exe" | 
               Where-Object { $_.FullName -match '\\test\\' } |
               ForEach-Object { $_.BaseName } |
               Sort-Object -Unique)
         }

         if ($exeFiles) {
            $candidateItems = ($exeFiles + (GetOptionsFpm -Subcmd $sub -Ast $commandAst)) | Where-Object { $_ -like "$wordToComplete*"}
         } else {
            $candidateItems = (GetOptionsFpm -Subcmd $sub -Ast $commandAst) | Where-Object { $_ -like "$wordToComplete*"}
         }

      } elseif ($sub -in $subCmdNoArg) {
         ## COMMANDs take no arguments: install, clean, manual, update, publish
         
         $candidateItems = (GetOptionsFpm -Subcmd $sub -Ast $commandAst) | Where-Object { $_ -like "$wordToComplete*"}
      } else {}
   }

   ### For debug
   # if (($sub -eq 'run')-or($sub -eq 'build')) {Write-Host "L30: exeFiles : $exeFiles"}
   # if ($sub -eq 'test') { Write-Host "L36: testFiles: $testExeFiles"}

   ### HELP handler
   $len = $commandAst.Extent.Text.Length
   if (( $currToken -eq 'help') -or ($prevToken -eq 'help')-or ($sub -eq 'help')) {
      if (($tokens.Count -ge 3) -and ($currToken -in $helpCommands) -and ($cursorPosition -ne $len)) {
         return $null
      } else {
         $candidateItems = ($helpCommands) | Where-Object { $_ -like "$wordToComplete*"}
      }
   }

   ### SUBCOMMAND COMLETION # IMPORTANT ##
   if (($currToken -in $fpmCommands -and $tokens.Count -eq 1) -or ($prevToken -in $fpmCommands -and $tokens.Count -eq 2 -and $currToken -notin $subCmd)) {
      $candidateItems = ($subCmd) | Where-Object { $_ -like "$wordToComplete*"}
   }

   ### If arguments are passed to the command, no completions provided.
   $line = $commandAst.Extent.Text
   if ($line -match '\s--\s') {
      return $null
   }

   foreach ($item in ($candidateItems | Where-Object {$_ -notin $tokens}))
   {

      $completionText = if ($item -match '"') {"$item"} else {"$item "}

      $listItemText = "$item";

      $toolTip = "'$item'";

      $resultType = [System.Management.Automation.CompletionResultType]::ParameterValue

      [System.Management.Automation.CompletionResult]::new($completionText, $listItemText, $resultType, $toolTip);
   }

}

Register-ArgumentCompleter -CommandName fpm -ScriptBlock $fpmCompletions
Register-ArgumentCompleter -CommandName fpm.exe -ScriptBlock $fpmCompletions