<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>ABC12345 AG Grid Demo</title>

<!--
  2026-06-11: ABC12345Jsp_TableDemo_JS.jsp をベースに、<table> 手書き描画を AG Grid に置き換えたサンプル。
  Tomcat 9 の webapps 配下に配置して、そのまま JSP として実行できます。
  注意：このサンプルは CDN を使用します。社内サーバーで外部通信不可の場合は、CSS/JS をローカル配置してください。
-->

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ag-grid-community@30.2.1/styles/ag-grid.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ag-grid-community@30.2.1/styles/ag-theme-alpine.css">
<script src="https://cdn.jsdelivr.net/npm/ag-grid-community@30.2.1/dist/ag-grid-community.min.js"></script>

<style>
    body {
        font-family: Meiryo, "MS Gothic", sans-serif;
        font-size: 13px;
        margin: 20px;
        background: #f7f7f7;
        color: #222;
    }
    .title {
        display: inline-block;
        margin: 10px 0 6px;
        font-weight: bold;
        font-size: 16px;
    }
    table.default_width {
        width: 100%;
        border-collapse: collapse;
        background: #fff;
    }
    td, th {
        border: 1px solid #999;
        padding: 5px 8px;
        white-space: nowrap;
    }
    .header_line {
        background: #d9e7f7;
        font-weight: bold;
        text-align: center;
    }
    .cond_data {
        margin: 8px 0 12px;
        padding: 10px;
        border: 1px solid #bbb;
        background: #fff;
        line-height: 1.8;
    }
    .button {
        padding: 4px 12px;
        margin-right: 4px;
        cursor: pointer;
    }
    .grid-wrapper {
        background: #fff;
        border: 1px solid #bbb;
        padding: 10px;
    }
    #myGrid {
        width: 100%;
        height: 460px;
    }
    .toolbar {
        margin: 8px 0;
        padding: 8px;
        background: #f2f6fb;
        border: 1px solid #ccd7e5;
    }
    .column-panel {
        margin-top: 8px;
        padding: 8px;
        background: #fff;
        border: 1px solid #ddd;
    }
    .column-panel label {
        display: inline-block;
        margin-right: 14px;
        margin-bottom: 6px;
        white-space: nowrap;
    }
    .summary-box {
        margin: 8px 0;
        padding: 8px;
        background: #fffbe8;
        border: 1px solid #e2d087;
    }
    .amount-cell {
        text-align: right;
    }
    .center-cell {
        text-align: center;
    }
    .ag-row-even {
        background: #ffffff;
    }
    .ag-row-odd {
        background: #f0f4fa;
    }
</style>

<script language="JavaScript1.2">
var PAGE_NAME = "一覧表示";
var BUTTON_NAME = "ABC12345";
var MAX_COUNT = 300;
var STORAGE_KEY = "AG_GRID_STATE";

var gridOptions;
var gridApi;
var columnApi;
var isRestoring = false;

// 実システムでは、この配列部分を Ajax/API の JSON 取得に置き換えます。
var tableData = [
    { date: "2026/05/01", code: "A001", name: "東京商事", giveTake: "受", amount: 120000, userRef: "USR-001", centerRef: "CTR-001", status: "OK", detail: "照合済" },
    { date: "2026/05/02", code: "A002", name: "大阪物産", giveTake: "渡", amount: 95000,  userRef: "USR-002", centerRef: "CTR-002", status: "NG", detail: "金額不一致" },
    { date: "2026/05/03", code: "A003", name: "千葉銀行", giveTake: "受", amount: 300000, userRef: "USR-003", centerRef: "CTR-003", status: "OK", detail: "正常" },
    { date: "2026/05/04", code: "A004", name: "横浜証券", giveTake: "渡", amount: 72500,  userRef: "USR-004", centerRef: "CTR-004", status: "WARN", detail: "要確認" },
    { date: "2026/05/05", code: "A005", name: "幕張開発", giveTake: "受", amount: 180000, userRef: "USR-005", centerRef: "CTR-005", status: "OK", detail: "照合済" },
    { date: "2026/05/06", code: "A006", name: "神田投信", giveTake: "受", amount: 230000, userRef: "USR-006", centerRef: "CTR-006", status: "OK", detail: "照合済" },
    { date: "2026/05/07", code: "A007", name: "品川ファンド", giveTake: "渡", amount: 64000, userRef: "USR-007", centerRef: "CTR-007", status: "WARN", detail: "リファレンス確認" },
    { date: "2026/05/08", code: "A008", name: "日本証券", giveTake: "受", amount: 450000, userRef: "USR-008", centerRef: "CTR-008", status: "OK", detail: "正常" },
    { date: "2026/05/09", code: "A009", name: "新宿銀行", giveTake: "渡", amount: 82000, userRef: "USR-009", centerRef: "CTR-009", status: "NG", detail: "コード不一致" },
    { date: "2026/05/10", code: "A010", name: "銀座商事", giveTake: "受", amount: 156000, userRef: "USR-010", centerRef: "CTR-010", status: "OK", detail: "照合済" },
    { date: "2026/05/11", code: "A011", name: "丸の内信託", giveTake: "受", amount: 340000, userRef: "USR-011", centerRef: "CTR-011", status: "OK", detail: "正常" },
    { date: "2026/05/12", code: "A012", name: "船橋開発", giveTake: "渡", amount: 118000, userRef: "USR-012", centerRef: "CTR-012", status: "WARN", detail: "要確認" }
];

var columnDefs = [
    {
        headerName: "決済日",
        field: "date",
        width: 120,
        filter: "agTextColumnFilter",
        cellClass: "center-cell"
    },
    {
        headerName: "コード",
        field: "code",
        width: 110,
        filter: "agTextColumnFilter",
        cellClass: "center-cell"
    },
    {
        headerName: "名称",
        field: "name",
        width: 160,
        filter: "agTextColumnFilter"
    },
    {
        headerName: "受渡",
        field: "giveTake",
        width: 90,
        filter: "agTextColumnFilter",
        cellClass: "center-cell"
    },
    {
        headerName: "決済金額",
        field: "amount",
        width: 130,
        filter: "agNumberColumnFilter",
        cellClass: "amount-cell",
        valueFormatter: function(params) {
            if (params.value === null || params.value === undefined || params.value === "") {
                return "";
            }
            return Number(params.value).toLocaleString("ja-JP");
        }
    },
    {
        headerName: "ユーザー リファレンスNO",
        field: "userRef",
        width: 180,
        filter: "agTextColumnFilter"
    },
    {
        headerName: "センタ リファレンスNO",
        field: "centerRef",
        width: 180,
        filter: "agTextColumnFilter"
    },
    {
        headerName: "照合状態",
        field: "status",
        width: 110,
        filter: "agTextColumnFilter",
        cellClass: "center-cell"
    },
    {
        headerName: "詳細",
        field: "detail",
        width: 180,
        filter: "agTextColumnFilter"
    }
];

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

function updateTitle() {
    document.getElementById("pageTitle").innerHTML = PAGE_NAME + "&nbsp;&nbsp;" + getCurrentTimeText();
    document.getElementById("buttonNameText").innerText = BUTTON_NAME;
}

function applyQuickFilter() {
    var keyword = document.getElementById("keyword").value || "";
    if (gridApi) {
        gridApi.setQuickFilter(keyword);
    }
}

function clearSearch() {
    document.getElementById("keyword").value = "";
    if (gridApi) {
        gridApi.setQuickFilter("");
        gridApi.setFilterModel(null);
    }
    updateSummary();
}

function updateSummary() {
    if (!gridApi) {
        return;
    }

    var count = 0;
    var totalAmount = 0;

    gridApi.forEachNodeAfterFilter(function(node) {
        count++;
        totalAmount += Number(node.data.amount || 0);
    });

    document.getElementById("resultCount").innerText = count;
    document.getElementById("amountTotal").innerText = totalAmount.toLocaleString("ja-JP");
}

function buildColumnPanel() {
    if (!columnApi) {
        return;
    }

    var panel = document.getElementById("columnPanel");
    panel.innerHTML = "";

    columnDefs.forEach(function(colDef) {
        var field = colDef.field;
        var column = columnApi.getColumn(field);
        var visible = column ? column.isVisible() : true;

        var label = document.createElement("label");
        var checkbox = document.createElement("input");
        checkbox.type = "checkbox";
        checkbox.checked = visible;
        checkbox.setAttribute("data-field", field);
        checkbox.onclick = function() {
            columnApi.setColumnVisible(field, checkbox.checked);
            saveGridState(false);
            updateSummary();
        };

        label.appendChild(checkbox);
        label.appendChild(document.createTextNode(" " + colDef.headerName));
        panel.appendChild(label);
    });
}

function saveGridState(showMessage) {
    if (!gridApi || !columnApi || isRestoring) {
        return;
    }

    var page = 0;
    if (gridApi.paginationGetCurrentPage) {
        page = gridApi.paginationGetCurrentPage();
    }

    var state = {
        columnState: columnApi.getColumnState(),
        filterModel: gridApi.getFilterModel(),
        quickFilterText: document.getElementById("keyword").value || "",
        currentPage: page
    };

    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));

    if (showMessage) {
        alert("Grid状態を保存しました。列幅、列順序、表示/非表示、フィルターなどを保存しています。");
    }
}

function restoreGridState(showMessage) {
    if (!gridApi || !columnApi) {
        return;
    }

    var saved = localStorage.getItem(STORAGE_KEY);
    if (!saved) {
        if (showMessage) {
            alert("保存済みのGrid状態がありません。");
        }
        return;
    }

    try {
        isRestoring = true;
        var state = JSON.parse(saved);

        if (state.columnState) {
            columnApi.applyColumnState({
                state: state.columnState,
                applyOrder: true
            });
        }

        if (state.filterModel) {
            gridApi.setFilterModel(state.filterModel);
        }

        if (state.quickFilterText !== undefined) {
            document.getElementById("keyword").value = state.quickFilterText;
            gridApi.setQuickFilter(state.quickFilterText);
        }

        if (state.currentPage !== undefined && gridApi.paginationGoToPage) {
            window.setTimeout(function() {
                gridApi.paginationGoToPage(state.currentPage);
            }, 0);
        }

        buildColumnPanel();
        updateSummary();

        if (showMessage) {
            alert("Grid状態を復元しました。");
        }
    } catch (e) {
        alert("保存状態の復元に失敗しました: " + e.message);
    } finally {
        isRestoring = false;
    }
}

function resetGridState() {
    if (!gridApi || !columnApi) {
        return;
    }

    localStorage.removeItem(STORAGE_KEY);
    document.getElementById("keyword").value = "";

    columnApi.resetColumnState();
    gridApi.setFilterModel(null);
    gridApi.setQuickFilter("");

    if (gridApi.paginationGoToFirstPage) {
        gridApi.paginationGoToFirstPage();
    }

    buildColumnPanel();
    updateSummary();
    alert("Grid状態を初期化しました。");
}

function createGrid() {
    gridOptions = {
        columnDefs: columnDefs,
        rowData: tableData.slice(0, MAX_COUNT),
        defaultColDef: {
            sortable: true,
            filter: true,
            resizable: true,
            floatingFilter: true
        },
        animateRows: true,
        suppressDragLeaveHidesColumns: true,
        rowSelection: "single",
        pagination: true,
        paginationPageSize: 5,
        onGridReady: function(params) {
            gridApi = params.api;
            columnApi = params.columnApi;
            restoreGridState(false);
            buildColumnPanel();
            updateSummary();
        },
        onFilterChanged: function() {
            updateSummary();
            saveGridState(false);
        },
        onSortChanged: function() {
            saveGridState(false);
        },
        onColumnMoved: function() {
            buildColumnPanel();
            saveGridState(false);
        },
        onColumnVisible: function() {
            buildColumnPanel();
            saveGridState(false);
        },
        onColumnResized: function(event) {
            if (event.finished) {
                saveGridState(false);
            }
        },
        onPaginationChanged: function() {
            updateSummary();
            saveGridState(false);
        }
    };

    var gridDiv = document.querySelector("#myGrid");
    new agGrid.Grid(gridDiv, gridOptions);
}

window.onload = function() {
    updateTitle();
    createGrid();
};
</script>
</head>

<body>
<form name="mainForm" method="post" action="javascript:void(0);">
    <input type="hidden" name="button_name" value="ABC12345">
    <input type="hidden" id="grid_state_key" name="grid_state_key" value="ABC12345_AG_GRID_STATE">

    <table cellspacing="0" cellpadding="5" border="3" class="default_width">
        <tr>
            <td id="pageTitle" class="title"></td>
        </tr>
    </table>

    <div class="cond_data">
        [区分：<span id="buttonNameText"></span>]<br>
        [検索条件：<input type="text" id="keyword" name="keyword" size="24" onkeydown="if(event.keyCode === 13){ applyQuickFilter(); return false; }">]
        <input class="button" type="button" value="検索" onclick="applyQuickFilter();">
        <input class="button" type="button" value="クリア" onclick="clearSearch();">
        <br>
        [件数：<span id="resultCount">0</span> 件]
        [金額合計：<span id="amountTotal">0</span>]
    </div>

    <div class="grid-wrapper">
        <label class="title">自社側決済指図（AG Grid版）</label>

        <div class="toolbar">
            <input class="button" type="button" value="Grid状態保存" onclick="saveGridState(true);">
            <input class="button" type="button" value="Grid状態復元" onclick="restoreGridState(true);">
            <input class="button" type="button" value="Grid状態初期化" onclick="resetGridState();">
            <span>列幅変更・列順序変更・列表示/非表示・フィルター状態を localStorage に保存します。</span>
        </div>

        <div class="column-panel">
            <strong>列表示 / 非表示：</strong>
            <span id="columnPanel"></span>
        </div>

        <div id="myGrid" class="ag-theme-alpine"></div>
    </div>
</form>
</body>
</html>
