//////////////////////////////////////////////////////////////////////////////// 
// ПРОЦЕДУРЫ И ФУНКЦИИ 
// 

// Функция извлекает из отбора формы списка значение элемента "владелец"
// 
// Возвращаемое значение: 
// СправочникСсылка.Товары, либо Неопределено, если владелец не найден
&НаКлиенте
Функция ПолучитьЗначениеВладельца()
	
	Для каждого Элемент из Список.Отбор.Элементы Цикл
		
		Если ТипЗнч(Элемент) =  Тип("ЭлементОтбораКомпоновкиДанных")
			 И (Строка(Элемент.ЛевоеЗначение) = "Владелец"
				ИЛИ Строка(Элемент.ЛевоеЗначение) = "Owner")
			 И Элемент.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно Тогда
			 
			Возврат Элемент.ПравоеЗначение;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

// Процедура получает список файлов, которые переданы на сервер и создает соответствующие элементы справочника
&НаСервере
Процедура СоздатьЭлементыСправочника(СписокЗагруженныхФайлов, Владелец)
	
	Для каждого ЗагруженныйФайл Из СписокЗагруженныхФайлов Цикл
		
		Файл = Новый Файл(ЗагруженныйФайл.Значение.Имя);
		ХранимыйФайл = Справочники.ХранимыеФайлы.СоздатьЭлемент();
		ХранимыйФайл.Владелец = Владелец;
		ХранимыйФайл.Наименование = Файл.Имя;
		ХранимыйФайл.ИмяФайла = Файл.Имя;
		ДвоичныеДанные = ПолучитьИзВременногоХранилища(ЗагруженныйФайл.Значение.Хранение);
		ХранимыйФайл.ДанныеФайла = Новый ХранилищеЗначения(ДвоичныеДанные, Новый СжатиеДанных());
		ХранимыйФайл.Записать();
		
	КонецЦикла;
	
КонецПроцедуры

// Функция формирует массив описаний передаваемых файлов по выделенным строкам списка
&НаКлиенте
Функция ОписаниеВыделенныхФайлов()
	
	ПередаваемыеФайлы = Новый Массив;
	Для каждого Строка Из Элементы.Список.ВыделенныеСтроки Цикл
		
		ДанныеСтроки = Элементы.Список.ДанныеСтроки(Строка);
		Ссылка = ПолучитьНавигационнуюСсылку(Строка, "ДанныеФайла");
		ПутьКфайлу = ДанныеСтроки.Код + "\" + ДанныеСтроки.ИмяФайла;
		Описание = Новый ОписаниеПередаваемогоФайла(ПутьКфайлу, Ссылка);
		ПередаваемыеФайлы.Добавить(Описание);
		
	КонецЦикла;
	
	Возврат ПередаваемыеФайлы;
	
КонецФункции

//////////////////////////////////////////////////////////////////////////////// 
// Обработчики команд
//

&НаКлиенте
Процедура ЗагрузитьФайлы()
	
	ОпПослеПодключенияРасширения = Новый ОписаниеОповещения("ЗагрузитьФайлы_ПослеПодключенияРасширения", ЭтотОбъект);
	НачатьПодключениеРасширенияРаботыСФайлами(ОпПослеПодключенияРасширения);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьФайлы_ПослеПодключенияРасширения(Подключено, Параметры) Экспорт
	
	Если Подключено Тогда
		
		Форма = ПолучитьФорму("Справочник.ХранимыеФайлы.Форма.ФормаЗагрузкиФайлов");
		Форма.Владелец = ПолучитьЗначениеВладельца();
		Форма.ОписаниеОповещенияОЗакрытии =
			Новый ОписаниеОповещения("ЗагрузитьФайлыЗавершение", ЭтотОбъект);
		Форма.Открыть();
		
	Иначе
		
		ПоказатьПредупреждение( ,
			НСтр("ru = 'Данная возможность недоступна, так как не подключено расширение работы с файлами.'", "ru"));
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьФайлыЗавершение(Результат, Параметры) Экспорт
	Если Не Результат = Неопределено Тогда
		СоздатьЭлементыСправочника(Результат.СписокЗагруженныхФайлов, Результат.Владелец);
		Элементы.Список.Обновить();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФайл()
	
	ПередаваемыеФайлы = ОписаниеВыделенныхФайлов();
	Если ПередаваемыеФайлы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	ОпПослеПодключенияРасширения = Новый ОписаниеОповещения("ОткрытьФайл_ПослеПодключенияРасширения", ЭтотОбъект, ПередаваемыеФайлы);
	НачатьПодключениеРасширенияРаботыСФайлами(ОпПослеПодключенияРасширения);
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФайл_ПослеПодключенияРасширения(РасширениеПодключено, ПередаваемыеФайлы) Экспорт
	
	Если РасширениеПодключено Тогда
		ОткрытьФайлыЧерезРасширение(ПередаваемыеФайлы);
	Иначе
		ОткрытьФайлыБезРасширения(ПередаваемыеФайлы);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФайлыБезРасширения(ПередаваемыеФайлы) 
	
	Для каждого Описание Из ПередаваемыеФайлы Цикл
		Фрагменты = СтрРазделить(Описание.Имя, "\");
		ПолучитьФайл(Описание.Хранение, Фрагменты[Фрагменты.ВГраница()]);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФайлыЧерезРасширение(ПередаваемыеФайлы) 
	
#Если НЕ МобильныйКлиент Тогда
	ОпПослеВыбораКаталога = Новый ОписаниеОповещения("ПослеВыбораКаталога", ЭтотОбъект, ПередаваемыеФайлы);
	Каталог = РаботаСХранилищемОбщихНастроек.ПолучитьРабочийКаталог();
	Если Каталог = Неопределено ИЛИ Каталог = "" Тогда
		Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
		Диалог.Заголовок = НСтр("ru = 'Выбор каталога временного хранения файлов'", "ru");
		Диалог.Показать(ОпПослеВыбораКаталога);
	Иначе
		ВыбранныеФайлы = Новый Массив;
		ВыбранныеФайлы.Добавить(Каталог);
		ВыполнитьОбработкуОповещения(ОпПослеВыбораКаталога, ВыбранныеФайлы);
	КонецЕсли;
#Иначе
	ОпПослеПолучениеКаталогаВременныхФайлов = Новый ОписаниеОповещения("ПолучениеКаталогаВременныхФайлов", ЭтотОбъект, ПередаваемыеФайлы);
	НачатьПолучениеКаталогаВременныхФайлов(ОпПослеПолучениеКаталогаВременныхФайлов);
#КонецЕсли
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучениеКаталогаВременныхФайлов(ИмяКаталогаВременныхФайлов, ПередаваемыеФайлы) Экспорт
	
	ВыбранныеФайлы = Новый Массив;
	ВыбранныеФайлы.Добавить(ИмяКаталогаВременныхФайлов);
	ПослеВыбораКаталога(ВыбранныеФайлы, ПередаваемыеФайлы);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеВыбораКаталога(ВыбранныеФайлы, ПередаваемыеФайлы) Экспорт
	
	Если ВыбранныеФайлы = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Каталог = ВыбранныеФайлы[0];
#Если НЕ МобильныйКлиент Тогда
	РаботаСХранилищемОбщихНастроек.СохранитьРабочийКаталог(Каталог);
#КонецЕсли
	
	Вызовы = Новый Массив;
	ВызовПолучитьФайлы =  Новый Массив;
	ВызовПолучитьФайлы.Добавить("НачатьПолучениеФайлов");
	ВызовПолучитьФайлы.Добавить(ПередаваемыеФайлы);
	ВызовПолучитьФайлы.Добавить("");
	ВызовПолучитьФайлы.Добавить(Ложь);
	Вызовы.Добавить(ВызовПолучитьФайлы);
	Для каждого Описание Из ПередаваемыеФайлы Цикл
		Описание.Имя = Каталог + "\" + Описание.Имя;
		ВызовЗапуститьПриложение =  Новый Массив;
		ВызовЗапуститьПриложение.Добавить("НачатьЗапускПриложения");
		ВызовЗапуститьПриложение.Добавить(Описание.Имя);
		Вызовы.Добавить(ВызовЗапуститьПриложение);
	КонецЦикла;
	
	ОпПослеЗапросаРазрешенийПользователя = Новый ОписаниеОповещения(
		"ПослеЗапросаРазрешенийПользователя", ЭтотОбъект, ПередаваемыеФайлы);
	НачатьЗапросРазрешенияПользователя(ОпПослеЗапросаРазрешенийПользователя, Вызовы);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗапросаРазрешенийПользователя(РазрешенияПолучены, ПередаваемыеФайлы) Экспорт
	
	Если НЕ РазрешенияПолучены Тогда
		Возврат;
	КонецЕсли;
	
	ОпПослеПолученияФайлов = Новый ОписаниеОповещения("ПослеПолученияФайлов", ЭтотОбъект);
	НачатьПолучениеФайлов(ОпПослеПолученияФайлов, ПередаваемыеФайлы, "", Ложь);
КонецПроцедуры

&НаКлиенте
Процедура ПослеПолученияФайлов(ПереданныеФайлы, ДопПараметры) Экспорт
	Если НЕ ПереданныеФайлы=Неопределено Тогда
		Для каждого Описание Из ПереданныеФайлы Цикл
			ОпПослеЗапускаПриложения = Новый ОписаниеОповещения(
				"ПослеЗапускаПриложения", ЭтотОбъект, Описание.Имя);
			НачатьЗапускПриложения(ОпПослеЗапускаПриложения, Описание.Имя);
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗапускаПриложения(КодВозврата, ИмяПриложения) Экспорт
	; // 
КонецПроцедуры
