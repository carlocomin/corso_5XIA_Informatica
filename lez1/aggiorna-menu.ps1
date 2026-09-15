$ErrorActionPreference = 'Stop'

$lessonTitles = [ordered]@{
    'lez1_1.html' = 'Perché nasce'
    'lez1_2.html' = 'Relazioni, tuple e domini'
    'lez1_3.html' = 'Vincoli di integrità'
    'lez1_4.html' = 'Superchiavi e chiavi'
    'lez1_5.html' = 'Chiavi esterne'
    'lez1_6.html' = 'Logico e fisico'
}

$menuPattern = [regex]::new(
    '  <details class="course-menu">.*?</details>',
    [System.Text.RegularExpressions.RegexOptions]::Singleline
)
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

foreach ($file in Get-ChildItem -LiteralPath $PSScriptRoot -Filter 'lez1_*.html' -File) {
    $items = foreach ($entry in $lessonTitles.GetEnumerator()) {
        $current = if ($entry.Key -eq $file.Name) { ' aria-current="page"' } else { '' }
        "        <li><a href=`"$($entry.Key)`"$current>$($entry.Value)</a></li>"
    }

    $menu = @"
  <details class="course-menu">
    <summary class="menu-toggle">☰ Indice</summary>
    <nav class="sidebar" aria-label="Indice della lezione 1">
      <h2>Lezione 1 · Modello relazionale</h2>
      <ol>
$($items -join "`n")
      </ol>
      <p><a href="../programma.html">← Programma del corso</a></p>
    </nav>
  </details>
"@

    $content = [System.IO.File]::ReadAllText($file.FullName)
    if ($menuPattern.Matches($content).Count -ne 1) {
        throw "Menu non individuato in $($file.FullName)"
    }

    $updated = $menuPattern.Replace($content, $menu, 1)
    if ($updated -ne $content) {
        [System.IO.File]::WriteAllText($file.FullName, $updated, $utf8NoBom)
        Write-Host "Menu aggiornato: $($file.Name)"
    }
}
