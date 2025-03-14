$subCmdNoArg = @("build", "clean", "install", "publish", "list", "manual", "update")
$subCmdWithArg = @("help", "new", "run", "test", "list")

$subCmds = @($subCmdNoArg + $subCmdWithArg)
$helpCmds = @($subCmds + "runner", "version", "fpm")

$stringTakeOptions = @( "--flag", "--c-flag", "--cxx-flag", "--link-flag", "--runner-args" )

$optionsWithoutSubCommand = @(
   '--version',
   '--list',
   '--help'
)

$optionsWithArgFpm = @(
   '--archiver',
   '--compiler',
   '--flag',
   '--c-compiler',
   '--c-flag',
   '--cxx-compiler',
   '--cxx-flag',
   '--link-flag',
   '--profile',
   '--runner',
   '--runner-args',
   '--target',
   '--dump',
   '--registry-cache',
   '--token',
   '--'
)

$optionsWithPathFpm = @(
   '--prefix',
   '--bindir',
   '--includedir',
   '--libdir',
   '--testdir'
)

$optionsNoArgFpm = @(
   '--clean',
   '--dry-run',
   '--version',
   '--help',
   '--verbose',
   '--all',
   '--skip',
   '--app',
   '--backfill',
   '--bare',
   '--example',
   '--full',
   '--src',
   '--lib',
   '--test',
   '--tests',
   '--list',
   '--no-prune',
   '--no-rebuild',
   '--dump',
   '--show-model',
   '--show-package-version',
   '--show-upload-data'
)

$wholeOptions = @($optionsWithArgFpm + $optionsWithPathFpm + $optionsNoArgFpm)

function AvailableCommandsFpm {
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

function DoesOptionHaveArgFpm {
   param (
      [string]$Option
   )
   if ($Option -notin $wholeOptions) {
      return $false
   }

   $tokens = $commandAst.Extent.Text -split '\s+'
   $lastIndex = $tokens.Count -1
   $index = [Array]::IndexOf($tokens, $Option)

   if ($index -ge 0) {
      if ($index -ne $lastIndex)  {
         if (($tokens[$index+1] -notin $wholeOptions) -and  -not ($tokens[$index+1] -match '^--.*')) {
            return $true
         }
      }
   }
   return $false
}

function DoesSubCmdHaveArgFpm {
   param (
      [string]$sub
   )
   if ($sub -notin $subCmds) {
      return $false
   }

   $tokens = $commandAst.Extent.Text -split '\s+'
   $lastIndex = $tokens.Count -1
   $index = [Array]::IndexOf($tokens, $sub)

   if ($index -ge 0) {
      if ($index -ne $lastIndex)  {
         if (($tokens[$index+1] -notin $subCmds) -and ($tokens[$index+1] -notin $wholeOptions) -and ($tokens[$index+1] -notmatch '^-+')) {
            return $true
         }
      }
   }
   return $false
}

function DoesOptionTakeArgFpm {
   param (
      [string]$flag
   )
   return ($flag -in $optionsWithArgFpm)

}
function DoesOptionTakePathFpm {
   param (
      [string]$flag
   )
   return ($flag -in $optionsWithPathFpm)
}

function GetOptionsFpm {
   param([string]$Subcmd,
         [System.Management.Automation.Language.CommandAst]$Ast
        )

   $tokens = @($Ast.CommandElements | ForEach-Object { $_.Value })

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
      "--tests",
      "--dump",
      "--verbose",
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
      "--no-prune"
      "--runner",
      "--runner-args",
      "--target",
      '--example'
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
      "--dump",
      "--help"
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

function FindProgramNamesFpm {
   $rootpath = FindManifestFpm
   $main = get-content (Join-Path $rootpath "fpm.toml") | Select-String '^name\s*=\s*"(.*?)"' | ForEach-Object {$_.Matches.Groups[1].Value}
   $appSrcFiles = @(Get-ChildItem -Path (Join-Path $rootpath app) -Recurse |
   Where-Object {$_.Extension -match '^\.(f90|F90|f|F)$'}| 
   ForEach-Object { $_.BaseName } |
   Sort-Object -Unique)

   if ($appSrcFiles -contains "main") {
      $appSrcFiles = $appSrcFiles | ForEach-Object { if ($_ -eq "main") { $main } else { $_ } }
   }
   
   return $appSrcFiles
}

function FindTestNamesFpm {
   $rootpath = FindManifestFpm
   $testSrcFiles = @(Get-ChildItem -Path (Join-Path $rootpath test) -Recurse |
   Where-Object {$_.Extension -match '^\.(f90|F90|f|F)$'}| 
   ForEach-Object { $_.BaseName } |
   Sort-Object -Unique)
   return $testSrcFiles
}

function FindExampleNamesFpm {
   $rootpath = FindManifestFpm
   $exampleSrcFiles = @(Get-ChildItem -Path (Join-Path $rootpath example) -Recurse |
   Where-Object {$_.Extension -match '^\.(f90|F90|f|F)$'}| 
   ForEach-Object { $_.BaseName } |
   Sort-Object -Unique)
   return $exampleSrcFiles
}

function OptionCompletionFpm {
   param(
      $flag, 
      $word2comp
   )

   # Options' arguments
   $FC = @("gfortran", "ifort", "ifx", "flang")
   $CC = @("cl", "gcc", "icx", "clang")
   $CXX = @("cl", "g++", "icx", "clang++")
   $AR = @("ar", "lib")
   $PROF = @("release", "debug")
   $runners = @("cafrun", "mpiexec", "mpirun", "gdb", "varglind")

   $tokens = @($commandAst.CommandElements | ForEach-Object { $_.Value })

   switch ($flag) {
      "--compiler" { $candidateItems = @( (AvailableCommandsFpm -Commands $FC) | Where-Object {$_ -like "$word2comp*"}) }
      '--flag' {$candidateItems = @('"')}
      '--c-compiler' { $candidateItems = @((AvailableCommandsFpm -Commands $CC)| Where-Object {$_ -like "$word2comp*"})}
      '--c-flag' {$candidateItems = '"'}
      '--cxx-compiler' { $candidateItems = @( (AvailableCommandsFpm -Commands $CXX) | Where-Object {$_ -like "$word2comp*"})}
      '--cxx-flag' {$candidateItems = '"'}
      '--profile' { $candidateItems = @( $PROF | Where-Object {$_ -like "$wordToComplete*"})}
      '--runner' { $candidateItems = @( (AvailableCommandsFpm -Commands $runners) | Where-Object {$_ -like "$word2comp*"} )}
      '--linker-flag' {$candidateItems = '"'}
      '--archiver' { $candidateItems = @((AvailableCommandsFpm -Commands $AR) | Where-Object {$_ -like "$word2comp*"})}
      '--runner-args' {$candidateItems = '" '}
      '--bindir' {}
      '--includedir' {}
      '--libdir' {}
      '--target' {
         $srcFiles = FindProgramNamesFpm
         if ('--all' -in $tokens) {
            return $null
         } else {
            if (($curr -notin $wholeOptions) -and ($prev -notin $wholeOptions)) {
               $candidateItems = @(@($srcFiles + @('--all')) | Where-Object  {$_ -like "$word2comp*"})
            } else {
               $candidateItems = @( $srcFiles | Where-Object  {$_ -like "$word2comp*"})
            }
         }
      }
      '--' {}
      default {return $null}
   }
   return $candidateItems
}

$fpmCompletions = {
   param($wordToComplete, $commandAst, $cursorPosition);

   $fpmCommands = @("fpm", "fpm.exe", "fpm-*")


   $tokens = @($commandAst.CommandElements | ForEach-Object { $_.Value })
   $prevToken = $tokens[-2]
   $currToken = $tokens[-1]

   if ($tokens.Count -ge 2) {
      $sub = $tokens[1]
   } else {
      $sub = ""
   }

   ### for debug
   # $projectRoot = FindManifestFpm
   # Write-Host "L250:"
   # Write-Host "L251: count:     "$tokens.Count
   # Write-Host "L252: sub-cmd:   '$sub'"
   # Write-Host "L253: prevToken: '$prevToken'"
   # Write-Host "L254: currToken: '$currToken'"
   # Write-Host "L255: project:   '$projectRoot'"
   #
   # $manifest = FindManifestFpm
   # $testFiles = FindTestNamesFpm
   # Write-Host "L278: tests $testFiles"
   # Write-Host "L279: manifest $manifest"
   # Write-Host "L280: Srcs: $srcFiles" 

#=================================================================================================#
   
   $condArgPrev = (DoesOptionTakeArgFpm -flag $prevToken)
   $condArgCurr = (DoesOptionTakeArgFpm -flag $currToken)
   $condPathPrev = (DoesOptionTakePathFpm -flag $prevToken)
   $condPathCurr = (DoesOptionTakePathFpm -flag $currToken)
   
   ## for debug
   # Write-Host "L295: condLast: $condArgPrev"
   # Write-Host "L296: condCurr: $condArgCurr"
   # Write-Host "L411: $condPathPrev"
   # Write-Host "L412: $condPathCurr"

   if (($condArgPrev -or $condArgCurr)) {

      $flag = if ($currToken -in $optionsWithArgFpm) {
         $currToken
      } elseif ($prevToken -in $optionsWithArgFpm) {
         $prevToken
      }

      $flagIndex = $tokens.IndexOf($flag)

      if ($flagIndex -ge 0) {

         # immediately after writing the flag.
         if ($flagIndex -eq $tokens.Length-1) {
            $candidateItems = OptionCompletionFpm -flag $flag -word2comp $wordToComplete
         }

         # inputting an argument
         $afterFlag = $tokens[$flagIndex +1]
         if ($wordToComplete -eq $afterFlag) {
            $candidateItems = OptionCompletionFpm -flag $flag -word2comp $wordToComplete | Where-Object {$_ -like "$wordToComplete*"}
         }

         # if it's not either of the above
         if ($candidateItems -eq $null) {
            $candidateItems = GetOptionsFpm -Subcmd $sub -Ast $commandAst
         }
         
      } 

   } elseif ($condPathPrev -or $condPathCurr){

      $flag = if ($currToken -in $optionsWithPathFpm) {
         $currToken
      } elseif ($prevToken -in $optionsWithPathFpm) {
         $prevToken
      }
      $flagIndex = $tokens.IndexOf($flag)

      if ($flagIndex -ge 0 -and ($flagIndex -eq $tokens.Length -1) -or ($flagIndex -eq $tokens.Length-1)) {

         switch ($flag) {
            '--bindir' { $subdir = 'bin'}
            '--libdir' { $subdir = 'lib'}
            '--includedir' { $subdir = 'include'}
            '--testdir' { $subdir = 'test'}
            '--prefix' { $subdir = $null }
            Default {$subdir = $null}
         }
         $dir = Join-Path ".local" $subdir
         
         ## Customized candidate path
         $customPaths = [System.Management.Automation.CompletionResult]::new(
            (Join-Path $HOME $dir),
            (Join-Path $HOME $dir),
            "ParameterValue",
            "Local custom path for fpm installation"
         )
         
         return $customPaths

      } else {
         $candidateItems = @(GetOptionsFpm -Subcmd $sub -Ast $commandAst) | Where-Object {$_ -like "$wordToComplete*"}
      }

   } else {

      if ($sub -in $subCmdWithArg) {
         $exeFiles = $null
         ## COMMANDs take some arguments: build, run, test, new
         if (($sub -eq 'run') -and ($tokens -contains '--example')) {
            $exeFiles = FindExampleNamesFpm

         } elseif ($sub -eq 'run') {
            $exeFiles = FindProgramNamesFpm

         } elseif ($sub -eq 'test') {
            $exeFiles = FindTestNamesFpm
         }

         if ($exeFiles) {
            $candidateItems = @(@($exeFiles) + @(GetOptionsFpm -Subcmd $sub -Ast $commandAst)) | Where-Object { $_ -like "$wordToComplete*"}
         } else {
            $candidateItems = @(GetOptionsFpm -Subcmd $sub -Ast $commandAst) | Where-Object { $_ -like "$wordToComplete*"}
         }

      } elseif ($sub -in $subCmdNoArg) {
         ## COMMANDs take no arguments: install, clean, manual, update, publish
         switch ($sub) {
            'install' { $candidateItems = @(GetOptionsFpm -Subcmd 'install' -Ast $commandAst) | Where-Object {$_ -like "$wordToComplete*"} }
            'clean' {$candidateItems = @(GetOptionsFpm -Subcmd 'clean' -Ast $commandAst) | Where-Object {$_ -like "$wordToComplete*"}}
            'manual' {return $null}
            'update' {$candidateItems = @(GetOptionsFpm -Subcmd 'update' -Ast $commandAst) | Where-Object {$_ -like "$wordToComplete*"}}
            'publish' {return $null}
            Default {return $null}
         }
      }
   }

   ### for debug
   # if ($sub -eq 'run') {Write-Host "L516: exeFiles : $exeFiles"}
   # if ($sub -eq 'test') { Write-Host "L617: testFiles: $testExeFiles"}

   ### HELP handler
   $len = $commandAst.Extent.Text.Length
   if (( $currToken -eq 'help') -or ($prevToken -eq 'help')-or ($sub -eq 'help')) {
      if (($tokens.Count -ge 3) -and ($currToken -in $helpCmds) -and ($cursorPosition -ne $len)) {
         return $null
      } else {
         $candidateItems = ($helpCmds) | Where-Object { $_ -like "$wordToComplete*"}
      }
   }

   ### SUBCOMMAND COMLETION # IMPORTANT ##
   if (($currToken -in $fpmCommands -and $tokens.Count -eq 1) -or ($prevToken -in $fpmCommands -and $tokens.Count -eq 2 -and $currToken -notin $subCmds)) {
      $candidateItems = @($subCmds + $optionsWithoutSubCommand) | Where-Object { $_ -like "$wordToComplete*"}
   }

   ### If arguments are passed to the command, no completions provided.
   $line = $commandAst.Extent.Text
   if ($line -match '\s--\s') {
      return $null
   }

#=================================================================================================#
   
   ### Filter just before completion.
   if ($currToken -eq '') {
      ## For flags that takes a string as an argument, no completion is performed.
      if ($prevToken -in $stringTakeOptions) {
         return $null
      }
   }
   if ($tokens -contains '--help' -or $tokens -contains '--version') {
      ## Do not complete further if `--version` or `--help` flag is present.
      return $null
   }

   ## Handling conflicting options
   if ($sub -eq 'run'){
      if (DoesOptionHaveArgFpm -Option '--target' ) {
         $candidateItems = $candidateItems | Where-Object {$_ -notmatch '--all'}
      }
      if (DoesSubCmdHaveArgFpm -sub 'run') {
         $candidateItems = $candidateItems | Where-Object {$_ -notmatch '--example'}
      }
      if (DoesOptionHaveArgFpm -Option '--example') {
         $candidateItems = $candidateItems | Where-Object {$_ -notmatch '--all'}
      }
   }
   if ($tokens.Count -gt 3){
      ## Do not include `--help` flag in suggestions if there are more than 3 tokens.
      $candidateItems = $candidateItems | Where-Object {$_ -notmatch '--help'}
   }

#=================================================================================================#
   
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