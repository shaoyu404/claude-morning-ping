# claude-morning-ping

用 Windows 工作排程器,在固定時間（例如上班前、午休時）呼叫一次 `claude.exe`，
藉此把 Claude Code 的使用 session 重置時間點，卡在自己想要的作息上，
讓一整段 session 剛好對齊實際的工作時間，減少 session 中途重置浪費掉的額度。

## 運作方式

`morning_claude.bat`：
- 讀取 `prompt.txt` 裡的提示詞，呼叫 `claude.exe -p "..."`
- 若當次呼叫失敗（例如 WiFi 暫時斷線），最多重試 5 次、間隔 60 秒
- 同一個場次（早上 / 中午）一天只需要成功一次，成功後會建立當日的
  `.session_ping_<日期>_<AM|PM>.flag` 標記檔，避免排程器重複觸發時浪費額度

## 為什麼把中文提示詞放在獨立的 prompt.txt

`cmd.exe` 在解析批次檔時，如果檔案內容直接內嵌多位元組的 UTF-8 字元（例如中文），
在特定情況下會因為內部讀取緩衝區沒對齊而整份解析錯亂，且是否會炸掉跟檔案長度造成
的位移量有關，相當不可靠。因此這裡把所有中文內容都移到外部的 `prompt.txt`，
執行時才用 `set /p` 讀進變數；`morning_claude.bat` 本身則完全只用 ASCII 字元，
從根本避開這個問題。

## 安裝

1. 把整個資料夾放到你想要的位置（`morning_claude.bat` 用 `%~dp0` 自動抓自己所在
   路徑，資料夾可以任意搬動）
2. 修改 `morning_claude.bat` 裡的 `CLAUDE` 變數，指向你自己的 `claude.exe` 路徑
3. 用 Windows「工作排程器」新增每日觸發（例如 07:00、12:00），動作指向
   `morning_claude.bat`
4. 建議在「設定」分頁勾選「錯過時間後盡快補跑」（Task Scheduler 的
   `StartWhenAvailable`），這樣即使電腦在觸發當下正在重開機 / 更新，
   也會在恢復後盡快補跑

## 檔案說明

| 檔案 | 用途 |
| --- | --- |
| `morning_claude.bat` | 主要執行腳本 |
| `prompt.txt` | 要傳給 claude 的提示詞內容 |

執行時會在同資料夾產生 `morning.log`（執行紀錄）與 `.session_ping_*.flag`
（當日成功標記），這兩種檔案不需要進版控，已加入 `.gitignore`。
