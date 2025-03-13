function fpmGetOptions {
   param([string]$Subcmd,
         [System.Management.Automation.Language.CommandAst]$Ast
        )

   $tokens = @($commandAst.CommandElements | ForEach-Object { $_.Value })


   $commonOptions = @("--version", "--help", "--verbose")

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

   $wholeOptions = @(($commonOptions + $cleanOptions + $newOptions + $installOptions + $testOptions) | Sort-Object -Unique)

   if ($subcmd -eq 'install') {
      @( $installOptions |  Where-Object{ $_ -notin $tokens})
   } elseif ($subcmd -eq 'clean'){
      @( $cleanOptions | Where-Object { $_ -notin $tokens})
   } elseif ($subcmd -eq 'run') {
      @( $runOptions | Where-Object {$_ -notin $tokens})
   } elseif ($Subcmd -eq 'build') {
      @( $buildOptions | Where-Object { $_ -notin $tokens})
   } elseif ($Subcmd -eq 'test') {
      @( $testOptions | Where-Object {$_ -notin $tokens})
   } else {
      $null
   }

}

$fpmCompletions = {
   param($wordToComplete, $commandAst, $cursorPosition);

   $fpmCommands = @("fpm", "fpm.exe", "fpm-*")

   # Subcommands
   $subCmdNoArg = @("clean", "install", "publish", "list", "manual", "update")
   $subCmdWithArg = @("build", "help", "new", "run", "test", "list")

   $subcommands = @($subCmdNoArg + $subCmdWithArg)
   $helpCommands = @($subcommands + "runner", "version", "fpm")

   # Options' arguments
   $FC = @("gfortran", "ifort", "ifx", "flang")
   $CC = @("gcc", "icx", "clang")
   $CXX = @("g++", "icx", "clang++")
   # runnnerの候補
   $runners = @("cafrun", "mpiexec", "mpirun", "gdb", "varglind")


   $tokens = @($commandAst.CommandElements | ForEach-Object { $_.Value })
   $len = $commandAst.Extent.Text.Length
   $lastToken = $tokens[-2]
   $currToken = $tokens[-1]

   if ($tokens.Count -ge 2) {
      $sub = $tokens[1]
   } else {
      $sub = ""
   }


   $filteredOptions = $options | Where-Object { $_ -notin $tokens }

   Write-Host "L26:"
   Write-Host "L27: count: "$tokens.Count
   Write-Host "L40: sub-cmd:   '$sub'"
   Write-Host "L28: lastToken: '$lastToken'"
   Write-Host "L29: currToken: '$currToken'"

   if (($sub -eq 'run')-or($sub -eq 'build')) {Write-Host "L30: exeFiles : $exeFiles"}
   if ($sub -eq 'test') { Write-Host "L36: testFiles: $testExeFiles"}


## 
   if (($sub -in $subCmdWithArg)) {
      ## COMMANDs take some arguments: build, run, test, new
   
      if (($sub -eq "build") -or ($sub -eq 'run')) {
         if ($IsWindows) {
            $exeFiles = @(Get-ChildItem -Path ".\build\*\app\*.exe" -File | ForEach-Object { $_.BaseName } | Sort-Object -Unique)
         } else {
            $exeFiles = @(Get-ChildItem -Path "./build/*/app/*" -File | ForEach-Object { $_.BaseName } | Sort-Object -Unique)
         }
      } elseif ($sub -eq 'test') {
         if ($IsWindows) {
            $exeFiles = @(Get-ChildItem -Path ".\build\*\test\*.exe" -File | ForEach-Object { $_.BaseName }| Sort-Object -Unique)
         } elseif ($IsLinux){
            $exeFiles = @(Get-ChildItem -Path "./build/*/test/*" -File | ForEach-Object { $_.BaseName }| Sort-Object -Unique)
         } else {
         }
      }

      if ($exeFiles) {
         $filteredItems = ($exeFiles + (fpmGetOptions -Subcmd $sub -Ast $commandAst)) | Where-Object { $_ -like "$wordToComplete*"}
      } else {
         $filteredItems = (fpmGetOptions -Subcmd $sub -Ast $commandAst) | Where-Object { $_ -like "$wordToComplete*"}
      }

   } elseif ($sub -in $subCmdNoArg) {
      ## COMMANDs take no arguments: install, clean, manual, update, publish
      
      $filteredItems = (fpmGetOptions -Subcmd $sub -Ast $commandAst) | Where-Object { $_ -like "$wordToComplete*"}
   } else {

   }

## HELP handler
   if (( $currToken -eq 'help') -or ($lastToken -eq 'help')-or ($sub -eq 'help')) {
      if (($tokens.Count -ge 3) -and ($currToken -in $helpCommands) -and ($cursorPosition -ne $len)) {
         return $null
      } else {
         $filteredItems = ($helpCommands) | Where-Object { $_ -like "$wordToComplete*"}
      }
      Write-Host "L164 Help"
   }

## SUBCOMMAND COMLETION # IMPORTANT ##
   if (($currToken -in $fpmCommands -and $tokens.Count -eq 1) -or ($lastToken -in $fpmCommands -and $tokens.Count -eq 2 -and $currToken -notin $subcommands)) {
      $filteredItems = ($subcommands) | Where-Object { $_ -like "$wordToComplete*"}
      Write-Host "L182 subcommand completion"
   }
######################################

   Write-Host "L173: filteredItems: " $filteredItems


   foreach ($item in $filteredItems)
   {

      $completionText = "$item "


      $listItemText = "$item";

      $toolTip = "'$item'";

      # $resultType = [System.Management.Automation.CompletionResultType]::ProviderItem;
      $resultType = [System.Management.Automation.CompletionResultType]::ParameterValue

      [System.Management.Automation.CompletionResult]::new($completionText, $listItemText, $resultType, $toolTip);
   }

}

Register-ArgumentCompleter -CommandName fpm -ScriptBlock $fpmCompletions;