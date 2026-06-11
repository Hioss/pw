<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>ABC12345 Tabulator Grid Demo</title>

<!--
  2026-06-11: 既存 JSP <table> 表示を Tabulator Grid 表示へ置き換えたサンプル。
  注意：このサンプルは CDN から Tabulator を読み込みます。閉域環境では CSS/JS をダウンロードしてローカル参照に変更してください。
-->
<link href="https://unpkg.com/tabulator-tables@6.3.1/dist/css/tabulator.min.css" rel="stylesheet">
<script src="https://unpkg.com/tabulator-tables@6.3.1/dist/js/tabulator.min.js"></script>

<style>
    body {
        font-family: Meiryo, "MS Gothic", sans-serif;
        font-size: 13px;
        margin: 20px;
        background: #f7f7f7;
        color: #222;
    }

    .title-table {
        width: 100%;
        border-collapse: collapse;
        background: #fff;
        margin-bottom: 10px;
    }

    .title-table td {
        border: 3px solid #999;
        padding: 8px;
        font-weight: bold;
        font-size: 16px;
    }

    .cond_data {
        margin: 8px 0 12px;
        padding: 10px;
        border: 1px solid #bbb;
        background: #fff;
        line-height: 1.9;
    }

    .button {
        padding: 4px 12px;
        margin-left: 4px;
        cursor: pointer;
    }

    .button-secondary {
        padding: 3px 10px;
        margin: 2px 4px 2px 0;
        cursor: pointer;
    }

    .section-title {
        display: inline-block;
        margin: 10px 0 6px;
        font-weight: bold;
        font-size: 16px;
    }

    .column-setting-area {
        margin: 8px 0 12px;
        padding: 8px;
        border: 1px solid #ccc;
        background: #fff;
    }

    .column-setting-area label {
        display: inline-block;
        margin-right: 12px;
        white-space: nowrap;
    }

    #gridArea {
        background: #fff;
    }

    /* 既存 JSP の header_line / odd_line / even_line に近い見た目へ調整 */
    .tabulator {
        border: 1px solid #999;
        font-size: 13px;
    }

    .tabulator .tabulator-header {
        background: #d9e7f7;
        border-bottom: 1px solid #999;
    }

    .tabulator .tabulator-header .tabulator-col {
        background: #d9e7f7;
        border-right: 1px solid #999;
        font-weight: bold;
        text-align: center;
    }

    .tabulator .tabulator-row .tabulator-cell {
        border-right: 1px solid #bbb;
        white-space: nowrap;
    }

    .tabulator .tabulator-row:nth-child(even) {
        background: #f0f4fa;
    }

    .tabulator .tabulator-row:nth-child(odd) {
        background: #ffffff;
    }

    .no-data-message {
        padding: 14px;
        border: 1px solid #999;
        background: #fff;
        text-align: center;
        font-weight: bold;
    }
</style>

<script language="JavaScript1.2">
// 2026-06-11: Tabulator 版。表の描画、検索、ソート、ページング、列状態保存を JavaScript 側で実行します。

var PAGE_NAME = "一覧表示";
var BUTTON_NAME = "ABC12345";
var MAX_COUNT = 300;
var STORAGE_KEY = "ABC12345_TABULATOR_GRID_STATE";

var table = null;

// 実システムでは、この配列部分を Ajax/API の JSON 取得、または JSP 側で出力した JSON に置き換えます。
var tableData = [
    { date: "2026/05/01", code: "A001", name: "東京商事", giveTake: "受", amount: 120000, userRef: "USR-001", centerRef: "CTR-001", status: "OK", detail: "照合済" },
    { date: "2026/05/02", code: "A002", name: "大阪物産", giveTake: "渡", amount: 95000,  userRef: "USR-002", centerRef: "CTR-002", status: "NG", detail: "金額不一致" },
    { date: "2026/05/03", code: "A003", name: "千葉銀行", giveTake: "受", amount: 300000, userRef: "USR-003", centerRef: "CTR-003", status: "OK", detail: "正常" },
    { date: "2026/05/04", code: "A004", name: "横浜証券", giveTake: "渡", amount: 72500,  userRef: "USR-004", centerRef: "CTR-004", status: "WARN", detail: "要確認" },
    { date: "2026/05/05", code: "A005", name: "幕張開発", giveTake: "受", amount: 180000, userRef: "USR-005", centerRef: "CTR-005", status: "OK", detail: "照合済" },
    { date: "2026/05/06", code: "A006", name: "名古屋信託", giveTake: "渡", amount: 54000,  userRef: "USR-006", centerRef: "CTR-006", status: "OK", detail: "照合済" },
    { date: "2026/05/07", code: "A007", name: "福岡産業", giveTake: "受", amount: 410000, userRef: "USR-007", centerRef: "CTR-007", status: "WARN", detail: "確認中" },
    { date: "2026/05/08", code: "A008", name: "札幌開発", giveTake: "渡", amount: 66500,  userRef: "USR-008", centerRef: "CTR-008", status: "OK", detail: "正常" },
    { date: "2026/05/09", code: "A009", name: "神戸商会", giveTake: "受", amount: 222000, userRef: "USR-009", centerRef: "CTR-009", status: "NG", detail: "コード不一致" },
    { date: "2026/05/10", code: "A010", name: "京都証券", giveTake: "渡", amount: 88000,  userRef: "USR-010", centerRef: "CTR-010", status: "OK", detail: "照合済" }
];

var columnDefs = [
    { title: "決済日", field: "date", width: 120, hozAlign: "center", headerFilter: "input" },
    { title: "コード", field: "code", width: 100, hozAlign: "center", headerFilter: "input" },
    { title: "名称", field: "name", width: 160, headerFilter: "input" },
    { title: "受渡", field: "giveTake", width: 80, hozAlign: "center", headerFilter: "list", headerFilterParams: { values: { "": "すべて", "受": "受", "渡": "渡" } } },
    { title: "決済金額", field: "amount", width: 130, hozAlign: "right", sorter: "number", formatter: "money", formatterParams: { precision: 0, thousand: "," }, bottomCalc: "sum", bottomCalcFormatter: "money", bottomCalcFormatterParams: { precision: 0, thousand: "," } },
    { title: "ユーザー\nリファレンスNO", field: "userRef", width: 170, headerFilter: "input" },
    { title: "センタ\nリファレンスNO", field: "centerRef", width: 170, headerFilter: "input" },
    { title: "照合状態", field: "status", width: 110, hozAlign: "center", headerFilter: "list", headerFilterParams: { values: { "": "すべて", "OK": "OK", "NG": "NG", "WARN": "WARN" } } },
    { title: "詳細", field: "detail", minWidth: 160, headerFilter: "input" }
];

function escapeHtml(value) {
    if (value === null || value === undefined) {
        return "";
    }
    return String(value)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/\"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

function getCurrentTimeText() {
    var now = new Date();
    var yyyy = now.getFullYear();
    var mm = String(now.getMonth() + 1).padStart(2, "0");
    var dd = String(now.getDate()).padStart(2, "0");
    var hh = String(now.getHours()).padStart(2, "0");
    var mi = String(now.getMinutes()).padStart(2, "0");
    var ss = String(now.getSeconds()).padStart(2, "0");
    return yyyy + "/" + mm + "/" + dd + " " + hh + ":" + mi + ":" + ss;
}

function globalKeywordFilter(data, params) {
    var keyword = String(params.keyword || "").trim().toLowerCase();

    if (keyword.length === 0) {
        return true;
    }

    return String(data.date).toLowerCase().indexOf(keyword) >= 0
        || String(data.code).toLowerCase().indexOf(keyword) >= 0
        || String(data.name).toLowerCase().indexOf(keyword) >= 0
        || String(data.giveTake).toLowerCase().indexOf(keyword) >= 0
        || String(data.amount).toLowerCase().indexOf(keyword) >= 0
        || String(data.userRef).toLowerCase().indexOf(keyword) >= 0
        || String(data.centerRef).toLowerCase().indexOf(keyword) >= 0
        || String(data.status).toLowerCase().indexOf(keyword) >= 0
        || String(data.detail).toLowerCase().indexOf(keyword) >= 0;
}

function searchGrid() {
    var keyword = document.getElementById("keyword").value;

    if (String(keyword || "").trim().length === 0) {
        table.clearFilter(false);
    } else {
        table.setFilter(globalKeywordFilter, { keyword: keyword });
    }

    document.getElementById("keyword_hidden").value = keyword;
    updateGridStatus();
}

function clearSearch() {
    document.getElementById("keyword").value = "";
    document.getElementById("keyword_hidden").value = "";
    table.clearFilter(false);
    table.clearHeaderFilter();
    updateGridStatus();
}

function saveGridState() {
    var state = {
        // 列幅、列順、表示/非表示を保存します。
        columnLayout: table.getColumnLayout(),
        sorters: table.getSorters(),
        keyword: document.getElementById("keyword").value,
        pageSize: table.getPageSize()
    };

    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    document.getElementById("stateMessage").innerText = "Grid 状態を保存しました。";
}

function restoreGridState() {
    var savedText = localStorage.getItem(STORAGE_KEY);

    if (!savedText) {
        return;
    }

    try {
        var state = JSON.parse(savedText);

        if (state.columnLayout) {
            table.setColumnLayout(state.columnLayout);
        }

        if (state.sorters) {
            table.setSort(state.sorters);
        }

        if (state.pageSize) {
            table.setPageSize(state.pageSize);
        }

        if (state.keyword) {
            document.getElementById("keyword").value = state.keyword;
            document.getElementById("keyword_hidden").value = state.keyword;
            table.setFilter(globalKeywordFilter, { keyword: state.keyword });
        }

        document.getElementById("stateMessage").innerText = "保存済み Grid 状態を復元しました。";
    } catch (e) {
        document.getElementById("stateMessage").innerText = "保存済み Grid 状態の復元に失敗しました。";
    }
}

function resetGridState() {
    localStorage.removeItem(STORAGE_KEY);
    document.getElementById("stateMessage").innerText = "保存済み Grid 状態を削除しました。画面を再読み込みします。";

    setTimeout(function() {
        location.reload();
    }, 500);
}

function updateGridStatus() {
    if (!table) {
        return;
    }

    var activeRows = table.getRows("active");
    var count = activeRows ? activeRows.length : 0;
    var sorters = table.getSorters();

    document.getElementById("resultCount").innerText = count;
    document.getElementById("sortStatus").innerText = sorters.length > 0 ? (sorters[0].field + " / " + sorters[0].dir) : "なし";
    document.getElementById("sort_key").value = sorters.length > 0 ? sorters[0].field : "";
    document.getElementById("sort_order").value = sorters.length > 0 ? sorters[0].dir : "";
}

function createColumnControlArea() {
    var area = document.getElementById("columnControlArea");
    area.innerHTML = "";

    columnDefs.forEach(function(col) {
        if (!col.field) {
            return;
        }

        var label = document.createElement("label");
        var checkbox = document.createElement("input");

        checkbox.type = "checkbox";
        checkbox.checked = true;
        checkbox.setAttribute("data-field", col.field);

        checkbox.onclick = function() {
            var column = table.getColumn(col.field);
            if (!column) {
                return;
            }

            if (checkbox.checked) {
                column.show();
            } else {
                column.hide();
            }

            updateColumnControlChecks();
        };

        label.appendChild(checkbox);
        label.appendChild(document.createTextNode(" " + col.title.replace(/\n/g, " ")));
        area.appendChild(label);
    });
}

function updateColumnControlChecks() {
    var checkboxes = document.querySelectorAll("#columnControlArea input[type='checkbox']");

    checkboxes.forEach(function(checkbox) {
        var field = checkbox.getAttribute("data-field");
        var column = table.getColumn(field);

        if (column) {
            checkbox.checked = column.isVisible();
        }
    });
}

function initGrid() {
    document.getElementById("pageTitle").innerHTML = escapeHtml(PAGE_NAME) + "&nbsp;&nbsp;" + escapeHtml(getCurrentTimeText());
    document.getElementById("buttonNameText").innerText = BUTTON_NAME;

    createColumnControlArea();

    table = new Tabulator("#gridArea", {
        data: tableData.slice(0, MAX_COUNT),
        columns: columnDefs,
        layout: "fitDataStretch",
        height: "520px",
        movableColumns: true,
        resizableColumnFit: false,
        pagination: true,
        paginationMode: "local",
        paginationSize: 5,
        paginationSizeSelector: [5, 10, 20, 50],
        placeholder: "対象データがありません。",
        initialSort: [
            { column: "date", dir: "asc" }
        ]
    });

    table.on("tableBuilt", function() {
        restoreGridState();
        updateColumnControlChecks();
        updateGridStatus();
    });

    table.on("dataFiltered", function(filters, rows) {
        document.getElementById("resultCount").innerText = rows.length;
    });

    table.on("dataSorted", function(sorters, rows) {
        updateGridStatus();
    });

    table.on("columnMoved", function(column, columns) {
        updateColumnControlChecks();
    });

    table.on("columnVisibilityChanged", function(column, visible) {
        updateColumnControlChecks();
    });

    table.on("pageLoaded", function(pageno) {
        updateGridStatus();
    });
}

window.onload = function() {
    initGrid();
};
</script>
</head>

<body>
<form name="mainForm" method="post" action="javascript:void(0);">
    <!-- 既存 JSP との互換用 hidden 項目。必要に応じてサーバー送信に利用できます。 -->
    <input type="hidden" name="button_name" value="ABC12345">
    <input type="hidden" id="sort_key" name="sort_key" value="date">
    <input type="hidden" id="sort_order" name="sort_order" value="asc">
    <input type="hidden" id="keyword_hidden" name="keyword_hidden" value="">

    <table cellspacing="0" cellpadding="5" border="0" class="title-table">
        <tr>
            <td id="pageTitle"></td>
        </tr>
    </table>

    <div class="cond_data">
        [区分：<span id="buttonNameText"></span>]<br>
        [検索条件：
            <input type="text" id="keyword" name="keyword" size="24" onkeydown="if(event.keyCode === 13){ searchGrid(); return false; }">
        ]
        <input class="button" type="button" value="検索" onclick="searchGrid();">
        <input class="button" type="button" value="クリア" onclick="clearSearch();">
        <br>
        [件数：<span id="resultCount">0</span> 件]
        [ソート：<span id="sortStatus">なし</span>]
    </div>

    <div class="column-setting-area">
        <strong>列表示設定：</strong>
        <div id="columnControlArea"></div>
        <input class="button-secondary" type="button" value="Grid状態保存" onclick="saveGridState();">
        <input class="button-secondary" type="button" value="保存状態リセット" onclick="resetGridState();">
        <span id="stateMessage"></span>
    </div>

    <label class="section-title">自社側決済指図</label>
    <div id="gridArea"></div>
</form>
</body>
</html>
