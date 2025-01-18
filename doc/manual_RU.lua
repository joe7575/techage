return {
  titles = {
    "1,Tech Age Mod",
    "2,Подсказки",
    "2,Изменения по сравнению с версией 1.0",
    "3,Советы по обновлению версии",
    "2,Руды и минералы",
    "3,Меридий",
    "3,Усмий",
    "3,Баборий",
    "3,Нефть",
    "3,Боксит",
    "3,Базальт",
    "2,History",
  },
  texts = {
    "Tech Age - это технологический мод с 5 стадиями развития:\n"..
    "\n"..
    "TA1: Железный век\n"..
    "Используйте инструменты и приспособления\\, такие как угольные печи\\, гравийные сита\\, молоты и бункеры\\, чтобы добывать и обрабатывать необходимые руды и металлы.\n"..
    "\n"..
    "TA2: Паровой век\n"..
    "Постройте паровой двигатель с механическим приводом и используйте его для работы своих первых машин по переработке руды.\n"..
    "\n"..
    "TA3: Нефтяной век\n"..
    "Найдите и добывайте нефть\\, постройте железные дороги для транспортировки нефти. Электростанция дает необходимое электричество для ваших машин. Электрический свет освещает ваши промышленные предприятия.\n"..
    "\n"..
    "TA4: Настоящее время\n"..
    "Возобновляемые источники энергии\\, такие как ветер\\, солнце и биотопливо\\, помогают вам покинуть нефтяной век. С помощью современных технологий и умных машин вы отправляетесь в будущее.\n"..
    "\n"..
    "TA5: Будущее\n"..
    "Машины\\, преодолевающие пространство и время\\, новые источники энергии и другие достижения определяют вашу жизнь.\n"..
    "\n"..
    "Примечание: Нажав на знак \"плюс\"\\, вы попадаете в подразделы этого руководства.\n"..
    "\n"..
    "\n"..
    "\n",
    "Эта документация доступна как \"в игре\" (план строительства блоков)\\, так и на GitHub в виде MD-файлов.\n"..
    "\n"..
    "  - Ссылка: https://github.com/joe7575/techage/wiki\n"..
    "\n"..
    "Строительные планы (схемы) для постройки машин и картинки доступны только в игре.\n"..
    "\n"..
    "В Tech Age вам придется начинать все сначала. Вы можете создавать блоки TA2 только с помощью предметов из TA1\\, для TA3 вам нужны результаты из TA2 и т.д.\n"..
    "\n"..
    "В TA2 машины работают только с приводными осями.\n"..
    "\n"..
    "В TA3 машины работают от электричества и имеют коммуникационный интерфейс для дистанционного управления.\n"..
    "\n"..
    "TA4 добавляет больше источников энергии\\, но также и более сложные логистические задачи (линии электропередач\\, транспортировка изделий).\n"..
    "\n",
    "С версии 1.0 (07/17/2021) изменилось следующее:\n"..
    "\n"..
    "  - Изменился алгоритм расчета распределения энергии. Это делает системы хранения энергии более важными. Они компенсируют колебания\\, что важно для больших сетей с несколькими генераторами.\n"..
    "  - По этой причине TA2 обзавелась собственным накопителем энергии.\n"..
    "  - Аккумуляторные блоки из TA3 также служат в качестве накопителей энергии. Их функциональность была соответствующим образом адаптирована.\n"..
    "  - Система хранения TA4 была пересмотрена. Теплообменник получил новый номер\\, поскольку его функциональность была перенесена с нижнего на средний блок. Если они управлялись дистанционно\\, номер узла должен быть адаптирован. Генераторы больше не имеют собственного меню\\, а включаются/выключаются только через теплообменник. Теплообменник и генератор теперь должны быть подключены к одной сети!\n"..
    "  - Несколько электросетей теперь могут быть соединены через трансформаторные блоки TA4.\n"..
    "  - Также появился блок счетчиков электроэнергии TA4 для подсетей.\n"..
    "  - Как минимум один блок аккумуляторов или система хранения в каждой сети\n"..
    "\n",
    "Многие другие блоки получили незначительные изменения. Поэтому возможно\\, что машины или системы не будут запускаться сразу после обновлению версии. В случае неполадок помогут следующие советы:\n"..
    "\n"..
    "  - выключите и снова включите машины\n"..
    "  - снимите блок силовых кабелей и установите его на место\n"..
    "  - полностью снимите блок и установите его на место\n"..
    "\n",
    "Techage добавляет в игру несколько новых предметов:\n"..
    "\n"..
    "  - Меридий - сплав для производства светящихся инструментов в TA1\n"..
    "  - Усмий - руда\\, которая добывается в TA2 и необходима для TA3\n"..
    "  - Бабориум - металл\\, необходимый для рецептов в TA3\n"..
    "  - Нефть - необходима в TA3\n"..
    "  - Боксит - алюминиевая руда\\, которая необходима в TA4 для производства алюминия\n"..
    "  - Базальт - возникает при соприкосновении воды и лав\n"..
    "\n",
    "Меридий - это сплав стали и кристаллов мезекона. Слитки меридиума можно изготовить с помощью угольной горелки из стали и кристаллов мезекона. Меридий светится в темноте. Инструменты из меридиума также светятся и поэтому очень полезны при подземной добыче.\n"..
    "\n"..
    "\n"..
    "\n",
    "Усмий встречается только в виде самородков и может быть получен только при промывке гравия с помощью системы промывки гравия TA2/TA3.\n"..
    "\n"..
    "\n"..
    "\n",
    "Барборий можно получить только при подземной добыче. Это вещество можно найти только на глубине от -250 до -340 метров.\n"..
    "\n"..
    "Бабориум можно переплавить только в промышленной печи TA3.\n"..
    "\n"..
    "\n"..
    "\n",
    "Нефть можно найти только с помощью Исследователя и добыть с помощью соответствующих машин TA3. См. TA3.\n"..
    "\n"..
    "\n"..
    "\n",
    "Боксит можно добыть только в подземной шахте. Боксит можно найти только в камне на высоте от -50 до -500 метров.\n"..
    "Он необходим для производства алюминия\\, который в основном используется в TA4.\n"..
    "\n"..
    "\n"..
    "\n",
    "Базальт образуется только при соединении лавы и воды.\n"..
    "Лучше всего создать систему\\, в которой лава и вода будут течь вместе.\n"..
    "Базальт образуется там\\, где встречаются обе жидкости.\n"..
    "Вы можете создать автоматический генератор базальта с помощью Sign Bot.\n"..
    "\n"..
    "\n"..
    "\n",
    "  - 28.09.2019: Solar system added\n"..
    "  - 05.10.2019: Data on the solar system and description of the inverter and the power terminal changed\n"..
    "  - 18.11.2019: Chapter for ores\\, reactor\\, aluminum\\, silo\\, bauxite\\, furnace heating\\, gravel washing system added\n"..
    "  - 22.02.2020: corrections and chapters on the update\n"..
    "  - 29.02.2020: ICTA controller added and further corrections\n"..
    "  - 14.03.2020 Lua controller added and further corrections\n"..
    "  - 22.03.2020 More TA4 blocks added\n"..
    "\n",
  },
  images = {
    "techage_ta4",
    "",
    "",
    "",
    "",
    "meridium",
    "usmium",
    "baborium",
    "oil",
    "bauxite",
    "basalt",
    "",
  },
  plans = {
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
  }
}