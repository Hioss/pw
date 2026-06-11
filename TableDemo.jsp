<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>JS Table Demo</title>
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
    .odd_line { background: #ffffff; }
    .even_line { background: #f0f4fa; }
    .odd_line_c, .even_line_c { text-align: center; }
    .odd_line_r, .even_line_r { text-align: right; }
    .cond_data {
        margin: 8px 0 12px;
        padding: 10px;
        border: 1px solid #bbb;
        background: #fff;
        line-height: 1.8;
    }
    .button { padding: 4px 12px; }
    a.sort {
        color: #003399;
        text-decoration: none;
        cursor: pointer;
    }
    a.sort:hover { text-decoration: underline; }
    .no-data { text-align: center; }
</style>
<script language="JavaScript1.2">
// 2026-06-11: JSP Scriptlet 版を JavaScript 中心の表示方式に変更したサンプル。
// 注意：このファイルは JSP として Tomcat に配置できますが、表の描画・検索・ソートは JavaScript で実行します。

var PAGE_NAME = "一覧表示";
var BUTTON_NAME = "ABC12345";
var MAX_COUNT = 300;

var sortKey = "date";
var sortOrder = "asc";

// 実システムでは、この配列部分を Ajax/API の JSON 取得に置き換えます。
var tableData = [
    { date: "2026/05/01", code: "A001", name: "東京商事", giveTake: "受", amount: 120000, userRef: "USR-001", centerRef: "CTR-001", status: "OK", detail: "照合済" },
    { date: "2026/05/02", code: "A002", name: "大阪物産", giveTake: "渡", amount: 95000,  userRef: "USR-002", centerRef: "CTR-002", status: "NG", detail: "金額不一致" },
    { date: "2026/05/03", code: "A003", name: "千葉銀行", giveTake: "受", amount: 300000, userRef: "USR-003", centerRef: "CTR-003", status: "OK", detail: "正常" },
    { date: "2026/05/04", code: "A004", name: "横浜証券", giveTake: "渡", amount: 72500,  userRef: "USR-004", centerRef: "CTR-004", status: "WARN", detail: "要確認" },
    { date: "2026/05/05", code: "A005", name: "幕張開発", giveTake: "受", amount: 180000, userRef: "USR-005", centerRef: "CTR-005", status: "OK", detail: "照合済" }
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

function formatAmount(value) {
    var numberValue = Number(value);
    if (isNaN(numberValue)) {
        return escapeHtml(value);
    }
    return numberValue.toLocaleString("ja-JP");
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

function filterRows(keyword) {
    var key = String(keyword || "").trim().toLowerCase();
    if (key.length === 0) {
        return tableData.slice(0);
    }

    return tableData.filter(function(row) {
        return String(row.date).toLowerCase().indexOf(key) >= 0
            || String(row.code).toLowerCase().indexOf(key) >= 0
            || String(row.name).toLowerCase().indexOf(key) >= 0
            || String(row.giveTake).toLowerCase().indexOf(key) >= 0
            || String(row.amount).toLowerCase().indexOf(key) >= 0
            || String(row.userRef).toLowerCase().indexOf(key) >= 0
            || String(row.centerRef).toLowerCase().indexOf(key) >= 0
            || String(row.status).toLowerCase().indexOf(key) >= 0
            || String(row.detail).toLowerCase().indexOf(key) >= 0;
    });
}

function sortRows(rows) {
    var direction = sortOrder === "desc" ? -1 : 1;

    return rows.sort(function(a, b) {
        var av = a[sortKey];
        var bv = b[sortKey];

        if (sortKey === "amount") {
            av = Number(av);
            bv = Number(bv);
            return direction * (av - bv);
        }

        av = String(av || "");
        bv = String(bv || "");
        if (av < bv) return -1 * direction;
        if (av > bv) return 1 * direction;
        return 0;
    });
}

function changeSort(key) {
    if (sortKey === key) {
        sortOrder = sortOrder === "asc" ? "desc" : "asc";
    } else {
        sortKey = key;
        sortOrder = "asc";
    }
    renderTable();
}

function clearSearch() {
    document.getElementById("keyword").value = "";
    renderTable();
}

function renderTable() {
    document.getElementById("pageTitle").innerHTML = escapeHtml(PAGE_NAME) + "&nbsp;&nbsp;" + escapeHtml(getCurrentTimeText());

    var keyword = document.getElementById("keyword").value;
    var rows = filterRows(keyword);
    sortRows(rows);

    if (rows.length > MAX_COUNT) {
        rows = rows.slice(0, MAX_COUNT);
    }

    document.getElementById("buttonNameText").innerText = BUTTON_NAME;
    document.getElementById("resultCount").innerText = rows.length;
    document.getElementById("sortStatus").innerText = sortKey + " / " + sortOrder;
    document.getElementById("sort_key").value = sortKey;
    document.getElementById("sort_order").value = sortOrder;

    var tbody = document.getElementById("resultBody");
    tbody.innerHTML = "";

    if (rows.length === 0) {
        document.getElementById("noDataArea").style.display = "block";
        document.getElementById("tableArea").style.display = "none";
        return;
    }

    document.getElementById("noDataArea").style.display = "none";
    document.getElementById("tableArea").style.display = "block";

    rows.forEach(function(row, index) {
        var lineClass = index % 2 === 0 ? "odd_line" : "even_line";
        var lineClassC = lineClass + "_c";
        var lineClassR = lineClass + "_r";

        var html = "";
        html += "<tr>";
        html += "<td class='" + lineClassC + "'>" + escapeHtml(row.date) + "</td>";
        html += "<td class='" + lineClassC + "'>" + escapeHtml(row.code) + "</td>";
        html += "<td class='" + lineClass + "'>" + escapeHtml(row.name) + "</td>";
        html += "<td class='" + lineClassC + "'>" + escapeHtml(row.giveTake) + "</td>";
        html += "<td class='" + lineClassR + "'>" + formatAmount(row.amount) + "</td>";
        html += "<td class='" + lineClass + "'>" + escapeHtml(row.userRef) + "</td>";
        html += "<td class='" + lineClass + "'>" + escapeHtml(row.centerRef) + "</td>";
        html += "<td class='" + lineClassC + "'>" + escapeHtml(row.status) + "</td>";
        html += "<td class='" + lineClass + "'>" + escapeHtml(row.detail) + "</td>";
        html += "</tr>";

        tbody.insertAdjacentHTML("beforeend", html);
    });
}

window.onload = function() {
    renderTable();
};
</script>
</head>
<body>
<form name="mainForm" method="post" action="javascript:void(0);">
    <input type="hidden" name="button_name" value="ABC12345">
    <input type="hidden" id="sort_key" name="sort_key" value="date">
    <input type="hidden" id="sort_order" name="sort_order" value="asc">

    <table cellspacing="0" cellpadding="5" border="3" class="default_width">
        <tr>
            <td id="pageTitle" class="title"></td>
        </tr>
    </table>

    <div class="cond_data">
        [区分：<span id="buttonNameText"></span>]<br>
        [検索条件：<input type="text" id="keyword" name="keyword" size="20" onkeydown="if(event.keyCode === 13){ renderTable(); return false; }">]
        <input class="button" type="button" value="検索" onclick="renderTable();">
        <input class="button" type="button" value="クリア" onclick="clearSearch();">
        <br>
        [件数：<span id="resultCount">0</span> 件]
        [ソート：<span id="sortStatus"></span>]
    </div>

    <div id="noDataArea" style="display:none;">
        <label class="title">検索結果</label>
        <table cellspacing="1" cellpadding="5" border="1" class="default_width">
            <tr><td class="header_line no-data">対象データがありません。</td></tr>
        </table>
    </div>

    <div id="tableArea">
        <label class="title">自社側決済指図</label>
        <table cellspacing="1" cellpadding="5" border="1" class="default_width">
            <thead>
                <tr>
                    <td class="header_line"><a class="sort" onclick="changeSort('date')">決済日</a></td>
                    <td class="header_line"><a class="sort" onclick="changeSort('code')">コード</a></td>
                    <td class="header_line"><a class="sort" onclick="changeSort('name')">名称</a></td>
                    <td class="header_line">受渡</td>
                    <td class="header_line"><a class="sort" onclick="changeSort('amount')">決済金額</a></td>
                    <td class="header_line">ユーザー<br>リファレンスNO</td>
                    <td class="header_line">センタ<br>リファレンスNO</td>
                    <td class="header_line"><a class="sort" onclick="changeSort('status')">照合状態</a></td>
                    <td class="header_line">詳細</td>
                </tr>
            </thead>
            <tbody id="resultBody"></tbody>
        </table>
    </div>
</form>
</body>
</html>
