$fpmGetOptions = {
   param($subcmd, $ast)
   
}

$fpmCompletions = {
   param($wordToComplete, $commandAst, $cursorPosition);

   $fpmCommands = @("fpm", "fpm.exe", "fpm-*")

   # Subcommands
   $subcommands = @("build", "clean", "help", "install", "new", "publish", "run", "test", "manual", "list", "update")
   $helpCommands = @("build", "clean", "help", "install", "new", "publish", "run", "test", "list", "runner", "manual", "version", "fpm")
   $noCompCommands = @("manual", "update")
   $ambiguousCommands = @("run", "runner")

   # Long Options
   $commonOptions = @("--version", "--help", "--verbose", "--runner", "--compiler")
   $cleanOptions = @("--all", "--skip")
   $newOptions = @("--app", "--backfill", "--bare", "--example", "--full", "--lib", "--src", "--test")
   $installOptions = @("--bindir", "--c-flag", "--cxx-flag", "--flag", "--includedir", "--libdir", "--link-flag", "--no-prone", "--no-rebuild", "--prefix", "--profile", "--test", "--testdir", "--verbose")
   $testOptions = @("--archiver", "--c-compiler", "--c-flag", "--compiler", "--cxx-compiler", "--cxx-flag", "--flag", "--help", "--list", "--", "--profile", "--runner", "--runner-args", "--target")

   $wholeOptions = @(($commonOptions + $cleanOptions + $newOptions + $installOptions + $testOptions) | Sort-Object -Unique)

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


   
   if (($currToken -eq 'help') -or ($lastToken -eq 'help')-or ($sub -eq 'help')) {
      if (($tokens.Count -ge 3) -and ($currToken -in $helpCommands) -and ($cursorPosition -ne $len)) {
         Write-Host "L55"
         return $null
      } else {
         $filteredItems = ($helpCommands) | Where-Object { $_ -like "$wordToComplete*"}
      }
      Write-Host "L58 help"

   } elseif (($currToken -eq 'run') -or ($lastToken -eq 'run') -or ($sub -eq 'run')) {
      $filteredItems = ($exeFiles) | Where-Object {$_ -notin $tokens}| Where-Object {$_ -like "$wordToComplete*" }
      Write-Host "L46 run"

   } elseif (($currToken -eq 'test') -or ($lastToken -eq 'test')-or ($sub -eq 'test')) {
      $filteredItems = ($testExeFiles + $testOptions) | Where-Object{ $_ -notin $tokens} | Where-Object { $_ -like "$wordToComplete*"}
      Write-Host "L50 test"

   } elseif (($currToken -eq 'clean') -or ($lastToken -eq 'clean')-or ($sub -eq 'clean')) {
      $filteredItems = ($cleanOptions) | Where-Object { $_ -like "$wordToComplete*"}
      Write-Host "L54 clean"

   
   } elseif (($currToken -eq 'build') -or ($lastToken -eq 'build')-or ($sub -eq 'build')) {
      $filteredItems = ($exeFiles) | Where-Object { $_ -like "$wordToComplete*"}
      Write-Host "L66 build"

   } elseif (($currToken -eq 'new') -or ($lastToken -eq 'new')-or ($sub -eq 'new')) {
      $filteredItems = ($newOptions) | Where-Object { $_ -like "$wordToComplete*"}
      Write-Host "L69 new"
   
   } elseif (($currToken -eq 'install') -or ($lastToken -eq 'install')-or ($sub -eq 'install')){
      $filteredItems = ($installOptions) | Where-Object { $_ -like "$wordToComplete*"}
      Write-Host "L72 install"

   } elseif (($currToken -eq 'list') -or ($lastToken -eq 'list') -or ($sub -eq 'list')) {
      return $null
   } elseif (($currToken -eq 'manual') -or ($lastToken -eq 'manual') -or ($sub -eq 'manual')) {
      return $null
   } elseif (($currToken -eq 'update') -or ($lastToken -eq 'update') -or ($sub -eq 'update')) {
      return $null
   } elseif ($sub -in $wholeOptions) {
      
   } else {
      Write-Host "L90: ELSE"
      Write-Host "`$wordToComplete の値: '[$wordToComplete]'" -ForegroundColor Yellow
      Write-Host "`$cursorPosition の値: $cursorPosition" -ForegroundColor Cyan
      Write-Host "`$commandAst.Extent.Text.Length の値: $($commandAst.Extent.Text.Length)" -ForegroundColor Cyan
      return $null
   }
############################################################################################
   
   if (($currToken -eq '--runner')-or  ($lastToken -eq '--runner')) {
      Write-Host "L77: --runner"
      $filteredItems = ($runnerCommands) | Where-Object { $_ -like "$wordToComplete*" }

   } elseif ($lastToken -eq '--compiler') {
      Write-Host "L81: --compiler"
      $filteredItems = ($compilerCommands) | Where-Object { $_ -like "$wordToComplete*"}

   } elseif (($currToken -in $fpmCommands -and $tokens.Count -eq 1) -or ($lastToken -in $fpmCommands -and $tokens.Count -eq 2 -and $currToken -notin $subcommands)) {
      $filteredItems = ($subcommands) | Where-Object { $_ -like "$wordToComplete*"}
      Write-Host "L88 fpm"
   } else {

      Write-Host "ELSE-Option"
      return $null
   }


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