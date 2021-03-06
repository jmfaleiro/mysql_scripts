/*
 * This file is released under the terms of the Artistic License.  Please see
 * the file LICENSE, included in this package, for details.
 *
 * Copyright (C) 2003 Mark Wong & Open Source Development Lab, Inc.
 * Copyright (C) 2004 Alexey Stroganov & MySQL AB.
 *
 * Based on TPC-C Standard Specification Revision 5.0 Clause 2.8.2.
 */

use fdr;
drop procedure if exists new_order_2;

delimiter |


CREATE PROCEDURE new_order_2 (in_w_id INT,
	                      in_d_id INT,
	                      in_ol_i_id INT,
	                      in_ol_quantity INT,
                              out tmp_s_dist VARCHAR(255))

BEGIN

DECLARE out_s_quantity INT;
DECLARE	tmp_s_data VARCHAR(255);

	IF in_d_id = 1 THEN
		SELECT s_quantity, s_dist_01, s_data
		INTO out_s_quantity, tmp_s_dist, tmp_s_data
		FROM STOCK
		WHERE s_i_id = in_ol_i_id
		  AND s_w_id = in_w_id;
	ELSEIF in_d_id = 2 THEN
		SELECT s_quantity, s_dist_02, s_data
		INTO out_s_quantity, tmp_s_dist, tmp_s_data
		FROM STOCK
		WHERE s_i_id = in_ol_i_id
		  AND s_w_id = in_w_id;
	ELSEIF in_d_id = 3 THEN
		SELECT s_quantity, s_dist_03, s_data
		INTO out_s_quantity, tmp_s_dist, tmp_s_data
		FROM STOCK
		WHERE s_i_id = in_ol_i_id
		  AND s_w_id = in_w_id;
	ELSEIF in_d_id = 4 THEN
		SELECT s_quantity, s_dist_04, s_data
		INTO out_s_quantity, tmp_s_dist, tmp_s_data
		FROM STOCK
		WHERE s_i_id = in_ol_i_id
		  AND s_w_id = in_w_id;
	ELSEIF in_d_id = 5 THEN
		SELECT s_quantity, s_dist_05, s_data
		INTO out_s_quantity, tmp_s_dist, tmp_s_data
		FROM STOCK
		WHERE s_i_id = in_ol_i_id
		  AND s_w_id = in_w_id;
	ELSEIF in_d_id = 6 THEN
		SELECT s_quantity, s_dist_06, s_data
		INTO out_s_quantity, tmp_s_dist, tmp_s_data
		FROM STOCK
		WHERE s_i_id = in_ol_i_id
		  AND s_w_id = in_w_id;
	ELSEIF in_d_id = 7 THEN
		SELECT s_quantity, s_dist_07, s_data
		INTO out_s_quantity, tmp_s_dist, tmp_s_data
		FROM STOCK
		WHERE s_i_id = in_ol_i_id
		  AND s_w_id = in_w_id;
	ELSEIF in_d_id = 8 THEN
		SELECT s_quantity, s_dist_08, s_data
		INTO out_s_quantity, tmp_s_dist, tmp_s_data
		FROM STOCK
		WHERE s_i_id = in_ol_i_id
		  AND s_w_id = in_w_id;
	ELSEIF in_d_id = 9 THEN
		SELECT s_quantity, s_dist_09, s_data
		INTO out_s_quantity, tmp_s_dist, tmp_s_data
		FROM STOCK
		WHERE s_i_id = in_ol_i_id
		  AND s_w_id = in_w_id;
	ELSEIF in_d_id = 10 THEN
		SELECT s_quantity, s_dist_10, s_data
		INTO out_s_quantity, tmp_s_dist, tmp_s_data
		FROM STOCK
		WHERE s_i_id = in_ol_i_id
		  AND s_w_id = in_w_id;
	END IF;

	IF out_s_quantity > in_ol_quantity + 10 THEN
		UPDATE STOCK
		SET s_quantity = s_quantity - in_ol_quantity
		WHERE s_i_id = in_ol_i_id
		  AND s_w_id = in_w_id;
	ELSE
		UPDATE STOCK
		SET s_quantity = s_quantity - in_ol_quantity + 91
		WHERE s_i_id = in_ol_i_id
		  AND s_w_id = in_w_id;
	END IF;

END|
delimiter ;

