.pragma library

var QUERY = {
    DBVER: "2.1",
    CREATE_HISTORY_TABLE: 'CREATE TABLE IF NOT EXISTS History(acId INTEGER UNIQUE, channelId INTEGER, '+
                          'name TEXT, previewurl TEXT, viewernum INTEGER, creatorName TEXT)'
}

var db = openDatabaseSync("AcFun", "", "AcFun Database", 1000000);

if (db.version !== QUERY.DBVER){
    var change = function (tx){
        tx.executeSql('DROP TABLE IF EXISTS History');
        tx.executeSql(QUERY.CREATE_HISTORY_TABLE);
    }
    db.changeVersion(db.version, QUERY.DBVER, change);
} else {
    var trans = function(tx){
        tx.executeSql(QUERY.CREATE_HISTORY_TABLE);
    }
    db.transaction(trans);
}

function storeHistory(acId, channelId, name, previewurl, viewernum, creatorName){
    db.transaction(function(tx){
                       tx.executeSql('INSERT OR REPLACE INTO History VALUES (?,?,?,?,?,?)',
                                     [acId, channelId, name, previewurl, viewernum, creatorName]);
                   })
}

function loadHistory(model){
    model.clear();
    db.readTransaction(function(tx){
                           var rs = tx.executeSql('SELECT * FROM History');
                           for (var i=rs.rows.length-1; i>=0; i--){
                               var prop = rs.rows.item(i);
                               prop.acId = Number(prop.acId);
                               prop.viewernum = Number(prop.viewernum);
                               prop.channelId = Number(prop.channelId);
                               model.append(prop);
                           }
                       })
}

function clearHistory(){
    db.transaction(function(tx){
                       tx.executeSql('DELETE FROM History');
                   })
}
