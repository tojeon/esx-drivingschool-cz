DrivingSchool = {}

DrivingSchool.debug = true
DrivingSchool.cashSymbol = '$'

DrivingSchool.school = {
    coords = vector3(225.8, -1400.4, 29.2),
    pedCoords = vector3(212.51, -1401.52, 29.22),
    pedHeading = 169.0,
    npcModel = 's_f_y_cop_01',
    interactionDistance = 3.5,
}

DrivingSchool.licenses = {
    A = {
        label = 'Kategorie A – motocykly',
        price = 500,
        vehicle = 'sanchez',
        places = {
            vec3(219.4, -1430.3, 29.2),
            vec3(292.2, -1491.8, 29.2),
            vec3(441.5, -1498.3, 29.2),
            vec3(492.9, -1388.6, 29.2),
            vec3(436.9, -1291.8, 29.2),
            vec3(288.1, -1266.3, 29.2),
            vec3(227.8, -1372.0, 29.2),
        },
        instructions = {
            'Zastavte u značky.',
            'Připravte se na odbočení doprava.',
            'Přesně projedete zatáčku.',
            'Předejte vozidlo přesně na značce.',
            'Znovu se rozjeďte a pokračujte.',
        }
    },
    B = {
        label = 'Kategorie B – osobní vozidla',
        price = 1500,
        vehicle = 'asea',
        places = {
            vec3(219.4, -1430.3, 29.2),
            vec3(295.2, -1495.6, 29.2),
            vec3(410.4, -1497.9, 29.2),
            vec3(508.0, -1420.1, 29.2),
            vec3(494.0, -1297.7, 29.2),
            vec3(387.2, -1264.2, 29.2),
            vec3(278.3, -1325.0, 29.2),
            vec3(225.8, -1405.2, 29.2),
        },
        instructions = {
            'Přepněte na 1. rychlost a rozjeďte se.',
            'Odbočte doprava na první křižovatce.',
            'Nestříhejte zatáčky a držte se správné dráhy.',
            'Zastavte na čáře.',
            'Vraťte se do školy a ukončete jízdní zkoušku.',
        }
    },
    C = {
        label = 'Kategorie C – nákladní vozidla',
        price = 3000,
        vehicle = 'mule3',
        places = {
            vec3(219.4, -1430.3, 29.2),
            vec3(278.5, -1489.8, 29.2),
            vec3(385.0, -1497.9, 29.2),
            vec3(509.0, -1426.8, 29.2),
            vec3(518.1, -1336.0, 29.2),
            vec3(433.6, -1269.0, 29.2),
            vec3(307.8, -1302.8, 29.2),
            vec3(227.9, -1374.6, 29.2),
        },
        instructions = {
            'Zvedněte ruky a zkontrolujte okolí.',
            'Rozjeďte těžké vozidlo opatrně.',
            'Odbočte na značce a nepřekračujte rychlost.',
            'Dopravte vozidlo přesně do zóny zastavení.',
            'Nákladní vozidlo musí být dokonale stabilní.',
        }
    },
}

DrivingSchool.questions = {
    A = {
        {
            question = 'Jaký je správný způsob zastavení při jízdě na motocyklu?',
            answers = {
                'Zastavit pomalu a bez prudkých pohybů.',
                'Zastavit v nejkratší cestě bez ohledu na stabilitu.',
                'Zastavit až po odbočení na silnici.',
                'Zastavit přesně ve 3. rychlosti.',
            },
            correct = 1,
        },
        {
            question = 'Co je zakázáno při jízdě motocyklem?',
            answers = {
                'Používání ochranné helmy.',
                'Jízda se zpomaleným tempem.',
                'Jízda bez držení obou rukou.',
                'Kontrola brzd po zastavení.',
            },
            correct = 3,
        },
        {
            question = 'Co znamená červená značka STOP?',
            answers = {
                'Přednost pro jízdu rovně.',
                'Povinnost zastavit a dát přednost.',
                'Návrat do školy.',
                'Zakázané parkování.',
            },
            correct = 2,
        },
        {
            question = 'Při jízdě v noci na motorce je správné:',
            answers = {
                'Snížit rychlost a zvolit rozumné tempo.',
                'Jezdit bez světel.',
                'Zvýšit rychlost v zatáčkách.',
                'Jezdít bez zrcátek.',
            },
            correct = 1,
        },
        {
            question = 'Kdy je zakázána jízda motocyklem?',
            answers = {
                'V případě poškozených brzd.',
                'Při použití přilby.',
                'Když je nevyhovující technický stav.',
                'Při údržbě vozidla.',
            },
            correct = 3,
        },
    },
    B = {
        {
            question = 'Kde je zakázáno zastavovat?',
            answers = {
                'Před křižovatkou za značkou STOP.',
                'Na vyhrazeném parkovišti pro invalidy.',
                'Na místě označeném jako zákaz zastavení.',
                'Na levé straně silnice.',
            },
            correct = 3,
        },
        {
            question = 'Co je správné při odbočení doprava?',
            answers = {
                'Odbočit bez signalizace.',
                'Signalizovat a zajistit bezpečnost.',
                'Překročit rychlost.',
                'Jet souběžně se zadem vozidla.',
            },
            correct = 2,
        },
        {
            question = 'Jak se chováte při průjezdu křižovatky?',
            answers = {
                'Jezdíte bez ohledu na světla.',
                'Dodržujete přednost a znamení.',
                'Jezdíte pouze podle hudby z rádia.',
                'Přerežete všem.',
            },
            correct = 2,
        },
        {
            question = 'Jak se správně řídí při dešti?',
            answers = {
                'Zvýšit rychlost a vjet do zatáčky.',
                'Zpomalit, zvýšit odstup a jezdit opatrně.',
                'Jezdit po všech pruzích.',
                'Odbočit nečekaně.',
            },
            correct = 2,
        },
        {
            question = 'Co je správná vzdálenost při jízdě?',
            answers = {
                'Přísně minimálně dva metry za vozidlem.',
                'Dostatečný odstup pro bezpečné brzdění.',
                'Bez rozdílu, hlavně rychle.',
                'Jedině při velikém provozu.',
            },
            correct = 2,
        },
    },
    C = {
        {
            question = 'Jaké bezpečnostní pravidlo platí pro nákladní vozidla?',
            answers = {
                'Jezdit bez zrcátek.',
                'Dodržovat rychlost a přepravní omezení.',
                'Jezdit bez zpětného zrcátka.',
                'Zajistit přetížení.',
            },
            correct = 2,
        },
        {
            question = 'Při řazení nákladního vozidla je důležité:',
            answers = {
                'Přepínat v nesprávné rychlosti.',
                'Mít dobrý přehled o zatížení a stability.',
                'Jezdit pouze na plné zrychlení.',
                'Rychle přepínat bez kontroly.',
            },
            correct = 2,
        },
        {
            question = 'Co je nejdůležitější při nákladu?',
            answers = {
                'Správné rozložení zátěže.',
                'Zrychlení na max.',
                'Vysoká rychlost v zatáčce.',
                'Bez zajištění zátěže.',
            },
            correct = 1,
        },
        {
            question = 'Kdo musí mít přednost při nákladním vozidle?',
            answers = {
                'Jízdní pruh je určující.',
                'Všichni ostatní musí respektovat nákladové vozidlo.',
                'Silniční provoz a bezpečnostní předpisy.',
                'Bez ohledu na signály.',
            },
            correct = 3,
        },
        {
            question = 'Při jízdě těžkým vozidlem je vhodné:',
            answers = {
                'Strkat do zatáček bez přehledu.',
                'Brzdit prudce a náhle.',
                'Jezdit opatrně a předvídatelně.',
                'Tlačit auto do mezní rychlosti.',
            },
            correct = 3,
        },
    },
}

return DrivingSchool
