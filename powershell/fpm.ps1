$fpmCompletions = {
   param($wordToComplete, $commandAst, $cursorPosition);

   # Subcommands
   $subcommands = @("build", "clean", "help", "install", "new", "publish", "run", "test")

   $helpcommands = @("build", "clean", "install", "new", "publish", "run", "test")


   # Long Options
   $options = @("--version", "--help", "--verbose", "--runner", "--compiler")
   
   # runnnerの候補
   $runnerCommands = @("cafrun", "mpiexec", "mpirun", "gdb", "varglind")

   # compilers
   $compilerCommands = @("gfortran", "ifort", "ifx", "flang")
   
   $exeFiles = Get-ChildItem -Path ".\build\*\app\*.exe" -File | ForEach-Object { $_.BaseName}


   $tokens = @($commandAst.CommandElements | ForEach-Object { $_.Value })
   $lastToken = $tokens[-2]
   $currToken = $tokens[-1]   

   $filteredOptions = $options | Where-Object { $_ -notin $tokens }

   Write-Host "L26:"
   Write-Host "L27: count: "$tokens.Count
   Write-Host "L28: lastToken: '$lastToken'"
   Write-Host "L29: currToken: '$currToken'"
   Write-Host "L30: exeFiles : $exeFiles"

   if (($currToken -eq "fpm" -and $tokens.Count -eq 1) -or ($lastToken -eq "fpm" -and $tokens.Count -eq 2)) {
      $filteredItems = ($subcommands) | Where-Object { $_ -like "$wordToComplete*"}

   } elseif (($currToken -eq 'run') -or ($lastToken -eq 'run') ) {
      $filteredItems = ($exeFiles) | Where-Object {$_ -like "$wordToComplete*" }

   } elseif ($lastToken -eq '--runner') {
      $filteredItems = ($runnerCommands) | Where-Object { $_ -like "$wordToComplete*" }

   } elseif ($lastToken -eq '--compiler') {
      $filteredItems = ($compilerCommands) | Where-Object { $_ -like "$wordToComplete*"}

   } elseif ($lastToken -eq 'help') {
      $filteredOptions = ($helpcommands) | Where-Object { $_ -like "$wordToComplete*"}
   } 
   else {
      $filteredItems = ($filteredOptions) | Where-Object { $_ -like "$wordToComplete*" }
   }

   foreach ($item in $filteredItems)
   {
      $completionText = "$item ";

      $listItemText = $item;

      $toolTip = "'$item' subcommand of fpm (Fortran Package Manager) command";

      # $resultType = [System.Management.Automation.CompletionResultType]::ProviderItem;
      $resultType = [System.Management.Automation.CompletionResultType]::ParameterValue;

      [System.Management.Automation.CompletionResult]::new($completionText, $listItemText, $resultType, $toolTip);
   }

}

Register-ArgumentCompleter -CommandName fpm -ScriptBlock $fpmCompletions;