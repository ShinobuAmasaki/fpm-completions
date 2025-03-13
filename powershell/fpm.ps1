function fpmGetOptions {
   param([string]$Subcmd,
         [System.Management.Automation.Language.CommandAst]$Ast
        )

   $tokens = @($commandAst.CommandElements | ForEach-Object { $_.Value })

   
   $commonOptions = @("--version", "--help", "--verbose")
   
   $cleanOptions = @("--all", "--skip")
   
   $newOptions = @(  "--app", 
                     "--backfill",
                     "--bare", 
                     "--example", 
                     "--full", 
                     "--lib", 
                     "--src", 
                     "--test"
                  )

   $installOptions =@(  "--bindir",
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

   $testOptions = @( "--archiver", 
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
      # Long Options

   $wholeOptions = @(($commonOptions + $cleanOptions + $newOptions + $installOptions + $testOptions) | Sort-Object -Unique)
   
      if ($subcmd -eq 'install') {
      @( $installOptions |  Where-Object{ $_ -notin $tokens})
   } else {
      $null
   }
      
}

$fpmCompletions = {
   param($wordToComplete, $commandAst, $cursorPosition);

   $fpmCommands = @("fpm", "fpm.exe", "fpm-*")

   # Subcommands
   $subcommands = @("build", "clean", "help", "install", "new", "publish", "run", "test",  "list", "manual", "update")
   $helpCommands = @($subcommands + "runner", "version", "fpm")
   $noCompCommands = @("manual", "update")
   $ambiguousCommands = @("run", "runner")


   # runnnerの候補
   $runnerCommands = @("cafrun", "mpiexec", "mpirun", "gdb", "varglind")

   # compilers
   $compilerCommands = @("gfortran", "ifort", "ifx", "flang")
   
   $exeFiles = @(Get-ChildItem -Path ".\build\*\app\*.exe" -File | ForEach-Object { $_.BaseName } | Sort-Object -Unique)
   $testExeFiles = @(Get-ChildItem -Path ".\build\*\test\*.exe" -File | ForEach-Object { $_.BaseName }| Sort-Object -Unique)

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


## HELP handler
   if (( 'help' -like "$currToken*") -or ($lastToken -eq 'help')-or ($sub -eq 'help')) {
      if (($tokens.Count -ge 3) -and ($currToken -in $helpCommands) -and ($cursorPosition -ne $len)) {
         return $null
      } else {
         $filteredItems = ($helpCommands) | Where-Object { $_ -like "$wordToComplete*"}
      }
   }

## IMPORTANT ##
   if (($currToken -in $fpmCommands -and $tokens.Count -eq 1) -or ($lastToken -in $fpmCommands -and $tokens.Count -eq 2 -and $currToken -notin $subcommands)) {
      $filteredItems = ($subcommands) | Where-Object { $_ -like "$wordToComplete*"}
      Write-Host "L182 subcommand completion"
   }
###############


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