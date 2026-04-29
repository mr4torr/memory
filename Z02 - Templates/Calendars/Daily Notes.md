<%*
const datePrefix = tp.date.now("YYYY-MM-DD");
const currentMonth = tp.date.now("YYYY-MM");
const dailyFolder = `B01 - Daily Notes/${currentMonth}`;
const dailyFilePath = `${dailyFolder}/${datePrefix}`;

await tp.file.move(dailyFilePath)

-%>

## 🎯 Atividades

```dataview
TABLE
  choice(numero_tarefa != "N/A", "[" + task + "](https://sua-empresa.atlassian.net/browse/" + numero_tarefa + ")", "-") AS "Tarefa",
  priority
FROM #task
WHERE scheduled = date("<% `${datePrefix}` %>")
SORT created ASC
```



## 📝 Observações



## 💬 Log de Comunicação
