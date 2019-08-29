package com.oltpbenchmark.benchmarks.adversary.procedures;

import com.oltpbenchmark.api.SQLStmt;

public class Q8 extends BaseQuery {

    public final SQLStmt insertStmt = new SQLStmt("INSERT INTO KV (K1, K2, V) VALUES (?, ?, ?), (?, ?, ?), (?, ?, ?), (?, ?, ?), (?, ?, ?), (?, ?, ?), (?, ?, ?), (?, ?, ?)");

    protected SQLStmt getInsertStmt() {
        return insertStmt;
    }
}