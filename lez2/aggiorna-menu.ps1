$ErrorActionPreference = 'Stop'

$lessonTitles = [ordered]@{
    'lez2_1.html' = 'Dal dominio al modello E-R'
    'lez2_2.html' = 'Entità, attributi e identificatori'
    'lez2_3.html' = 'Relazioni, ruoli e cardinalità'
    'lez2_4.html' = 'Entità deboli'
    'lez2_5.html' = 'Tipi di attributo'
    'lez2_6.html' = 'Gerarchie EER'
    'lez2_7.html' = 'Traduzione relazionale'
}

$menuPattern = [regex]::new(
    '  <details class="course-menu">.*?</details>',
    [System.Text.RegularExpressions.RegexOptions]::Singleline
)
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

foreach ($file in Get-ChildItem -LiteralPath $PSScriptRoot -Filter 'lez2_*.html' -File) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $newline = [regex]::Match($content, '\r?\n').Value
    $items = foreach ($entry in $lessonTitles.GetEnumerator()) {
        $current = if ($entry.Key -eq $file.Name) { ' aria-current="page"' } else { '' }
        '        <li><a href="{0}"{1}>{2}</a></li>' -f $entry.Key, $current, $entry.Value
    }

    $menuLines = @(
        '  <details class="course-menu">'
        '    <summary class="menu-toggle">☰ Indice</summary>'
        '    <nav class="sidebar" aria-label="Indice della lezione 2">'
        '      <h2>Lezione 2 · Modello E-R</h2>'
        '      <ol>'
    ) + $items + @(
        '      </ol>'
        '      <p><a href="../programma.html">← Programma del corso</a></p>'
        '    </nav>'
        '  </details>'
    )
    $menu = $menuLines -join $newline

    if ($menuPattern.Matches($content).Count -ne 1) {
        throw "Menu non individuato in $($file.FullName)"
    }

    $updated = $menuPattern.Replace($content, $menu, 1)
    if ($updated -ne $content) {
        [System.IO.File]::WriteAllText($file.FullName, $updated, $utf8NoBom)
        Write-Host "Menu aggiornato: $($file.Name)"
    }
}
