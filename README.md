CREATE TABLE IF NOT EXISTS `driving_school_licenses` (
    `identifier` VARCHAR(50) NOT NULL,
    `category` VARCHAR(10) NOT NULL,
    `has_license` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`identifier`, `category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `driving_school_questions` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `category` VARCHAR(10) NOT NULL,
    `question` TEXT NOT NULL,
    `answer_1` TEXT NOT NULL,
    `answer_2` TEXT NOT NULL,
    `answer_3` TEXT NOT NULL,
    `answer_4` TEXT NOT NULL,
    `correct_answer` TINYINT(1) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `driving_school_questions` (`category`, `question`, `answer_1`, `answer_2`, `answer_3`, `answer_4`, `correct_answer`) VALUES
('A', 'Jaký je správný způsob zastavení při jízdě na motocyklu?', 'Zastavit pomalu a bez prudkých pohybů.', 'Zastavit na maximální rychlosti.', 'Zastavit bez použití brzd.', 'Zastavit po odbočení.', 1),
('A', 'Co je zakázáno při jízdě motocyklem?', 'Používání ochranné helmy.', 'Jízda se zpomaleným tempem.', 'Jízda bez držení obou rukou.', 'Kontrola brzd po zastavení.', 3),
('A', 'Co znamená červená značka STOP?', 'Přednost pro jízdu rovně.', 'Povinnost zastavit a dát přednost.', 'Návrat do školy.', 'Zakázané parkování.', 2),
('A', 'Při jízdě v noci na motorce je správné:', 'Snížit rychlost a zvolit rozumné tempo.', 'Jezdit bez světel.', 'Zvýšit rychlost v zatáčkách.', 'Jezdit bez zrcátek.', 1),
('A', 'Kdy je zakázána jízda motocyklem?', 'V případě poškozených brzd.', 'Při použití přilby.', 'Když je vozidlo v dobrém stavu.', 'Při údržbě vozidla.', 1),
('B', 'Kde je zakázáno zastavovat?', 'Před křižovatkou za značkou STOP.', 'Na vyhrazeném parkovišti pro invalidy.', 'Na místě označeném jako zákaz zastavení.', 'Na levé straně silnice.', 3),
('B', 'Co je správné při odbočení doprava?', 'Odbočit bez signalizace.', 'Signalizovat a zajistit bezpečnost.', 'Překročit rychlost.', 'Jet souběžně se zadem vozidla.', 2),
('B', 'Jak se chováte při průjezdu křižovatky?', 'Jezdíte bez ohledu na světla.', 'Dodržujete přednost a znamení.', 'Jezdíte pouze podle hudby z rádia.', 'Přerežete všem.', 2),
('B', 'Jak se správně řídí při dešti?', 'Zvýšit rychlost a vjet do zatáčky.', 'Zpomalit, zvýšit odstup a jezdit opatrně.', 'Jezdit po všech pruzích.', 'Odbočit nečekaně.', 2),
('B', 'Co je správná vzdálenost při jízdě?', 'Přísně minimálně dva metry za vozidlem.', 'Dostatečný odstup pro bezpečné brzdění.', 'Bez rozdílu, hlavně rychle.', 'Jedině při velikém provozu.', 2),
('C', 'Jaké bezpečnostní pravidlo platí pro nákladní vozidla?', 'Jezdit bez zrcátek.', 'Dodržovat rychlost a přepravní omezení.', 'Jezdit bez zpětného zrcátka.', 'Zajistit přetížení.', 2),
('C', 'Při řazení nákladního vozidla je důležité:', 'Přepínat v nesprávné rychlosti.', 'Mít dobrý přehled o zatížení a stability.', 'Jezdit pouze na plné zrychlení.', 'Rychle přepínat bez kontroly.', 2),
('C', 'Co je nejdůležitější při nákladu?', 'Správné rozložení zátěže.', 'Zrychlení na max.', 'Vysoká rychlost v zatáčce.', 'Bez zajištění zátěže.', 1),
('C', 'Kdo musí mít přednost při nákladním vozidle?', 'Jízdní pruh je určující.', 'Všichni ostatní musí respektovat nákladové vozidlo.', 'Silniční provoz a bezpečnostní předpisy.', 'Bez ohledu na signály.', 3),
('C', 'Při jízdě těžkým vozidlem je vhodné:', 'Strkat do zatáček bez přehledu.', 'Brzdit prudce a náhle.', 'Jezdit opatrně a předvídatelně.', 'Tlačit auto do mezní rychlosti.', 3);

CREATE TABLE IF NOT EXISTS `driving_school_tests` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(50) NOT NULL,
    `category` VARCHAR(10) NOT NULL,
    `theory_passed` TINYINT(1) NOT NULL DEFAULT 0,
    `driving_passed` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
