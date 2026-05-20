-- Boutique de Guitare — Tests unitaires utPLSQL
-- Exécution : EXEC ut.run(); ou EXEC ut.run('test_pkg_fabricants');

-- ── FABRICANTS ───────────────────────────────────────────────
CREATE OR REPLACE PACKAGE test_pkg_fabricants AS
    --%suite(Tests Fabricants)
    --%rollback(manual)
    --%test(GET ALL retourne une liste non nulle)
    PROCEDURE test_get_all;
    --%test(CREATE insertion valide)
    PROCEDURE test_create_valide;
    --%test(CREATE nom vide leve exception)
    --%throws(-20002)
    PROCEDURE test_create_nom_vide;
    --%test(GET BY ID retourne le bon enregistrement)
    PROCEDURE test_get_by_id_valide;
    --%test(GET BY ID inexistant leve exception)
    --%throws(-20001)
    PROCEDURE test_get_by_id_inexistant;
    --%test(UPDATE mise a jour reussie)
    PROCEDURE test_update_valide;
    --%test(UPDATE ID inexistant leve exception)
    --%throws(-20001)
    PROCEDURE test_update_inexistant;
    --%test(DELETE suppression reussie)
    PROCEDURE test_delete_valide;
    --%test(DELETE ID inexistant leve exception)
    --%throws(-20001)
    PROCEDURE test_delete_inexistant;
END test_pkg_fabricants;
/
CREATE OR REPLACE PACKAGE BODY test_pkg_fabricants AS
    FUNCTION f_ins(p_nom VARCHAR2) RETURN NUMBER IS v_id NUMBER; BEGIN
        INSERT INTO fabricants(nom_manu) VALUES(p_nom) RETURNING id_manu INTO v_id; RETURN v_id;
    END;
    PROCEDURE test_get_all IS v_n NUMBER; BEGIN
        INSERT INTO fabricants(nom_manu) VALUES('T_GA'); COMMIT;
        SELECT COUNT(*) INTO v_n FROM fabricants;
        ut.expect(v_n).to_be_greater_than(0);
        DELETE FROM fabricants WHERE nom_manu='T_GA'; COMMIT;
    END;
    PROCEDURE test_create_valide IS v_id NUMBER; v_nom VARCHAR2(100); BEGIN
        v_id := f_ins('T_Create'); COMMIT;
        SELECT nom_manu INTO v_nom FROM fabricants WHERE id_manu=v_id;
        ut.expect(v_nom).to_equal('T_Create');
        DELETE FROM fabricants WHERE id_manu=v_id; COMMIT;
    END;
    PROCEDURE test_create_nom_vide IS BEGIN pkg_fabricants.create_one(p_nom=>'   '); END;
    PROCEDURE test_get_by_id_valide IS v_id NUMBER; v_nom VARCHAR2(100); BEGIN
        v_id := f_ins('T_GetById'); COMMIT;
        SELECT nom_manu INTO v_nom FROM fabricants WHERE id_manu=v_id;
        ut.expect(v_nom).to_equal('T_GetById');
        DELETE FROM fabricants WHERE id_manu=v_id; COMMIT;
    END;
    PROCEDURE test_get_by_id_inexistant IS v_r fabricants%ROWTYPE; BEGIN
        SELECT * INTO v_r FROM fabricants WHERE id_manu=999999;
    END;
    PROCEDURE test_update_valide IS v_id NUMBER; v_nom VARCHAR2(100); BEGIN
        v_id := f_ins('T_Avant'); COMMIT;
        UPDATE fabricants SET nom_manu='T_Apres' WHERE id_manu=v_id; COMMIT;
        SELECT nom_manu INTO v_nom FROM fabricants WHERE id_manu=v_id;
        ut.expect(v_nom).to_equal('T_Apres');
        DELETE FROM fabricants WHERE id_manu=v_id; COMMIT;
    END;
    PROCEDURE test_update_inexistant IS BEGIN pkg_fabricants.update_one(p_id=>999999,p_nom=>'X'); END;
    PROCEDURE test_delete_valide IS v_id NUMBER; v_n NUMBER; BEGIN
        v_id := f_ins('T_Del'); COMMIT;
        DELETE FROM fabricants WHERE id_manu=v_id; COMMIT;
        SELECT COUNT(*) INTO v_n FROM fabricants WHERE id_manu=v_id;
        ut.expect(v_n).to_equal(0);
    END;
    PROCEDURE test_delete_inexistant IS BEGIN pkg_fabricants.delete_one(p_id=>999999); END;
END test_pkg_fabricants;
/

-- ── CLIENTS ──────────────────────────────────────────────────
CREATE OR REPLACE PACKAGE test_pkg_clients AS
    --%suite(Tests Clients)
    --%rollback(manual)
    --%test(GET ALL retourne une liste non nulle)
    PROCEDURE test_get_all;
    --%test(CREATE insertion valide)
    PROCEDURE test_create_valide;
    --%test(CREATE nom vide leve exception)
    --%throws(-20012)
    PROCEDURE test_create_nom_vide;
    --%test(GET BY ID retourne le bon client)
    PROCEDURE test_get_by_id_valide;
    --%test(GET BY ID inexistant leve exception)
    --%throws(-20011)
    PROCEDURE test_get_by_id_inexistant;
    --%test(UPDATE mise a jour reussie)
    PROCEDURE test_update_valide;
    --%test(UPDATE ID inexistant leve exception)
    --%throws(-20011)
    PROCEDURE test_update_inexistant;
    --%test(DELETE suppression reussie)
    PROCEDURE test_delete_valide;
    --%test(DELETE cascade sur les paniers)
    PROCEDURE test_delete_cascade;
    --%test(DELETE ID inexistant leve exception)
    --%throws(-20011)
    PROCEDURE test_delete_inexistant;
END test_pkg_clients;
/
CREATE OR REPLACE PACKAGE BODY test_pkg_clients AS
    FUNCTION f_ins(p_nom VARCHAR2) RETURN NUMBER IS v_id NUMBER; BEGIN
        INSERT INTO clients(nom_client) VALUES(p_nom) RETURNING id_client INTO v_id; RETURN v_id;
    END;
    PROCEDURE test_get_all IS v_n NUMBER; BEGIN
        INSERT INTO clients(nom_client) VALUES('T_GA'); COMMIT;
        SELECT COUNT(*) INTO v_n FROM clients; ut.expect(v_n).to_be_greater_than(0);
        DELETE FROM clients WHERE nom_client='T_GA'; COMMIT;
    END;
    PROCEDURE test_create_valide IS v_id NUMBER; v_nom VARCHAR2(100); BEGIN
        v_id := f_ins('T_Create_Cli'); COMMIT;
        SELECT nom_client INTO v_nom FROM clients WHERE id_client=v_id;
        ut.expect(v_nom).to_equal('T_Create_Cli');
        DELETE FROM clients WHERE id_client=v_id; COMMIT;
    END;
    PROCEDURE test_create_nom_vide IS BEGIN pkg_clients.create_one(p_nom=>NULL); END;
    PROCEDURE test_get_by_id_valide IS v_id NUMBER; v_nom VARCHAR2(100); BEGIN
        v_id := f_ins('T_GetById_Cli'); COMMIT;
        SELECT nom_client INTO v_nom FROM clients WHERE id_client=v_id;
        ut.expect(v_nom).to_equal('T_GetById_Cli');
        DELETE FROM clients WHERE id_client=v_id; COMMIT;
    END;
    PROCEDURE test_get_by_id_inexistant IS v_r clients%ROWTYPE; BEGIN
        SELECT * INTO v_r FROM clients WHERE id_client=999999;
    END;
    PROCEDURE test_update_valide IS v_id NUMBER; v_nom VARCHAR2(100); BEGIN
        v_id := f_ins('T_Avant_Cli'); COMMIT;
        UPDATE clients SET nom_client='T_Apres_Cli' WHERE id_client=v_id; COMMIT;
        SELECT nom_client INTO v_nom FROM clients WHERE id_client=v_id;
        ut.expect(v_nom).to_equal('T_Apres_Cli');
        DELETE FROM clients WHERE id_client=v_id; COMMIT;
    END;
    PROCEDURE test_update_inexistant IS BEGIN pkg_clients.update_one(p_id=>999999,p_nom=>'X'); END;
    PROCEDURE test_delete_valide IS v_id NUMBER; v_n NUMBER; BEGIN
        v_id := f_ins('T_Del_Cli'); COMMIT;
        DELETE FROM clients WHERE id_client=v_id; COMMIT;
        SELECT COUNT(*) INTO v_n FROM clients WHERE id_client=v_id; ut.expect(v_n).to_equal(0);
    END;
    PROCEDURE test_delete_cascade IS v_id_c NUMBER; v_id_p NUMBER; v_n NUMBER; BEGIN
        v_id_c := f_ins('T_Cascade'); INSERT INTO paniers(id_client) VALUES(v_id_c) RETURNING id_panier INTO v_id_p; COMMIT;
        DELETE FROM clients WHERE id_client=v_id_c; COMMIT;
        SELECT COUNT(*) INTO v_n FROM paniers WHERE id_panier=v_id_p; ut.expect(v_n).to_equal(0);
    END;
    PROCEDURE test_delete_inexistant IS BEGIN pkg_clients.delete_one(p_id=>999999); END;
END test_pkg_clients;
/

-- ── PRODUITS ─────────────────────────────────────────────────
CREATE OR REPLACE PACKAGE test_pkg_produits AS
    --%suite(Tests Produits)
    --%rollback(manual)
    --%test(GET ALL retourne liste avec jointure fabricant)
    PROCEDURE test_get_all;
    --%test(CREATE valide avec fabricant)
    PROCEDURE test_create_avec_fabricant;
    --%test(CREATE valide sans fabricant)
    PROCEDURE test_create_sans_fabricant;
    --%test(CREATE nom vide leve exception)
    --%throws(-20022)
    PROCEDURE test_create_nom_vide;
    --%test(CREATE prix negatif leve exception)
    --%throws(-20023)
    PROCEDURE test_create_prix_negatif;
    --%test(GET BY ID retourne le bon produit)
    PROCEDURE test_get_by_id_valide;
    --%test(GET BY ID inexistant leve exception)
    --%throws(-20021)
    PROCEDURE test_get_by_id_inexistant;
    --%test(GET BY FABRICANT filtre correct)
    PROCEDURE test_get_by_fabricant;
    --%test(UPDATE mise a jour reussie)
    PROCEDURE test_update_valide;
    --%test(UPDATE ID inexistant leve exception)
    --%throws(-20021)
    PROCEDURE test_update_inexistant;
    --%test(DELETE suppression reussie)
    PROCEDURE test_delete_valide;
    --%test(DELETE ID inexistant leve exception)
    --%throws(-20021)
    PROCEDURE test_delete_inexistant;
END test_pkg_produits;
/
CREATE OR REPLACE PACKAGE BODY test_pkg_produits AS
    FUNCTION f_fab RETURN NUMBER IS v_id NUMBER; BEGIN
        INSERT INTO fabricants(nom_manu) VALUES('T_Fab_Prod') RETURNING id_manu INTO v_id; RETURN v_id;
    END;
    FUNCTION f_prod(p_nom VARCHAR2, p_prix NUMBER, p_manu NUMBER DEFAULT NULL) RETURN NUMBER IS v_id NUMBER; BEGIN
        INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES(p_nom,p_prix,p_manu) RETURNING id_produit INTO v_id; RETURN v_id;
    END;
    PROCEDURE test_get_all IS v_n NUMBER; BEGIN
        INSERT INTO produits(nom_produit,prix_produit) VALUES('T_GA',100); COMMIT;
        SELECT COUNT(*) INTO v_n FROM produits; ut.expect(v_n).to_be_greater_than(0);
        DELETE FROM produits WHERE nom_produit='T_GA'; COMMIT;
    END;
    PROCEDURE test_create_avec_fabricant IS v_f NUMBER; v_p NUMBER; v_m NUMBER; BEGIN
        v_f := f_fab; v_p := f_prod('T_AvecFab',500,v_f); COMMIT;
        SELECT id_manu INTO v_m FROM produits WHERE id_produit=v_p;
        ut.expect(v_m).to_equal(v_f);
        DELETE FROM produits WHERE id_produit=v_p; DELETE FROM fabricants WHERE id_manu=v_f; COMMIT;
    END;
    PROCEDURE test_create_sans_fabricant IS v_p NUMBER; v_n NUMBER; BEGIN
        v_p := f_prod('T_SansFab',300,NULL); COMMIT;
        SELECT COUNT(*) INTO v_n FROM produits WHERE id_produit=v_p; ut.expect(v_n).to_equal(1);
        DELETE FROM produits WHERE id_produit=v_p; COMMIT;
    END;
    PROCEDURE test_create_nom_vide IS BEGIN pkg_produits.create_one(p_nom=>'',p_prix=>100); END;
    PROCEDURE test_create_prix_negatif IS BEGIN pkg_produits.create_one(p_nom=>'X',p_prix=>-10); END;
    PROCEDURE test_get_by_id_valide IS v_p NUMBER; v_prix NUMBER; BEGIN
        v_p := f_prod('T_GetById',1999.99); COMMIT;
        SELECT prix_produit INTO v_prix FROM produits WHERE id_produit=v_p;
        ut.expect(v_prix).to_equal(1999.99);
        DELETE FROM produits WHERE id_produit=v_p; COMMIT;
    END;
    PROCEDURE test_get_by_id_inexistant IS v_r produits%ROWTYPE; BEGIN SELECT * INTO v_r FROM produits WHERE id_produit=999999; END;
    PROCEDURE test_get_by_fabricant IS v_f NUMBER; v_n NUMBER; BEGIN
        v_f := f_fab;
        INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('T_F1',100,v_f);
        INSERT INTO produits(nom_produit,prix_produit,id_manu) VALUES('T_F2',200,v_f); COMMIT;
        SELECT COUNT(*) INTO v_n FROM produits WHERE id_manu=v_f; ut.expect(v_n).to_equal(2);
        DELETE FROM produits WHERE id_manu=v_f; DELETE FROM fabricants WHERE id_manu=v_f; COMMIT;
    END;
    PROCEDURE test_update_valide IS v_p NUMBER; v_prix NUMBER; BEGIN
        v_p := f_prod('T_Upd',800); COMMIT;
        UPDATE produits SET prix_produit=950 WHERE id_produit=v_p; COMMIT;
        SELECT prix_produit INTO v_prix FROM produits WHERE id_produit=v_p;
        ut.expect(v_prix).to_equal(950);
        DELETE FROM produits WHERE id_produit=v_p; COMMIT;
    END;
    PROCEDURE test_update_inexistant IS BEGIN pkg_produits.update_one(p_id=>999999,p_nom=>'X',p_prix=>1); END;
    PROCEDURE test_delete_valide IS v_p NUMBER; v_n NUMBER; BEGIN
        v_p := f_prod('T_Del',300); COMMIT;
        DELETE FROM produits WHERE id_produit=v_p; COMMIT;
        SELECT COUNT(*) INTO v_n FROM produits WHERE id_produit=v_p; ut.expect(v_n).to_equal(0);
    END;
    PROCEDURE test_delete_inexistant IS BEGIN pkg_produits.delete_one(p_id=>999999); END;
END test_pkg_produits;
/

-- ── PANIERS ──────────────────────────────────────────────────
CREATE OR REPLACE PACKAGE test_pkg_paniers AS
    --%suite(Tests Paniers)
    --%rollback(manual)
    --%test(GET ALL retourne liste avec nom client)
    PROCEDURE test_get_all;
    --%test(CREATE insertion valide)
    PROCEDURE test_create_valide;
    --%test(CREATE client NULL leve exception)
    --%throws(-20032)
    PROCEDURE test_create_sans_client;
    --%test(CREATE client inexistant leve exception)
    --%throws(-20033)
    PROCEDURE test_create_client_inexistant;
    --%test(GET BY ID retourne le bon panier)
    PROCEDURE test_get_by_id_valide;
    --%test(GET BY ID inexistant leve exception)
    --%throws(-20031)
    PROCEDURE test_get_by_id_inexistant;
    --%test(GET BY CLIENT filtre correct)
    PROCEDURE test_get_by_client;
    --%test(UPDATE changement de client)
    PROCEDURE test_update_valide;
    --%test(UPDATE ID inexistant leve exception)
    --%throws(-20031)
    PROCEDURE test_update_inexistant;
    --%test(DELETE suppression reussie)
    PROCEDURE test_delete_valide;
    --%test(DELETE ID inexistant leve exception)
    --%throws(-20031)
    PROCEDURE test_delete_inexistant;
END test_pkg_paniers;
/
CREATE OR REPLACE PACKAGE BODY test_pkg_paniers AS
    FUNCTION f_cli(p_nom VARCHAR2) RETURN NUMBER IS v_id NUMBER; BEGIN
        INSERT INTO clients(nom_client) VALUES(p_nom) RETURNING id_client INTO v_id; RETURN v_id;
    END;
    FUNCTION f_pan(p_id_cli NUMBER) RETURN NUMBER IS v_id NUMBER; BEGIN
        INSERT INTO paniers(id_client) VALUES(p_id_cli) RETURNING id_panier INTO v_id; RETURN v_id;
    END;
    PROCEDURE test_get_all IS v_c NUMBER; v_n NUMBER; BEGIN
        v_c := f_cli('T_Pan_GA'); INSERT INTO paniers(id_client) VALUES(v_c); COMMIT;
        SELECT COUNT(*) INTO v_n FROM paniers; ut.expect(v_n).to_be_greater_than(0);
        DELETE FROM paniers WHERE id_client=v_c; DELETE FROM clients WHERE id_client=v_c; COMMIT;
    END;
    PROCEDURE test_create_valide IS v_c NUMBER; v_p NUMBER; v_n NUMBER; BEGIN
        v_c := f_cli('T_Pan_Cre'); v_p := f_pan(v_c); COMMIT;
        SELECT COUNT(*) INTO v_n FROM paniers WHERE id_panier=v_p; ut.expect(v_n).to_equal(1);
        DELETE FROM paniers WHERE id_panier=v_p; DELETE FROM clients WHERE id_client=v_c; COMMIT;
    END;
    PROCEDURE test_create_sans_client IS BEGIN pkg_paniers.create_one(p_id_client=>NULL); END;
    PROCEDURE test_create_client_inexistant IS BEGIN pkg_paniers.create_one(p_id_client=>999999); END;
    PROCEDURE test_get_by_id_valide IS v_c NUMBER; v_p NUMBER; v_n NUMBER; BEGIN
        v_c := f_cli('T_Pan_Get'); v_p := f_pan(v_c); COMMIT;
        SELECT COUNT(*) INTO v_n FROM paniers WHERE id_panier=v_p; ut.expect(v_n).to_equal(1);
        DELETE FROM paniers WHERE id_panier=v_p; DELETE FROM clients WHERE id_client=v_c; COMMIT;
    END;
    PROCEDURE test_get_by_id_inexistant IS v_r paniers%ROWTYPE; BEGIN SELECT * INTO v_r FROM paniers WHERE id_panier=999999; END;
    PROCEDURE test_get_by_client IS v_c NUMBER; v_n NUMBER; BEGIN
        v_c := f_cli('T_Pan_ByC');
        INSERT INTO paniers(id_client) VALUES(v_c);
        INSERT INTO paniers(id_client) VALUES(v_c); COMMIT;
        SELECT COUNT(*) INTO v_n FROM paniers WHERE id_client=v_c; ut.expect(v_n).to_equal(2);
        DELETE FROM paniers WHERE id_client=v_c; DELETE FROM clients WHERE id_client=v_c; COMMIT;
    END;
    PROCEDURE test_update_valide IS v_c1 NUMBER; v_c2 NUMBER; v_p NUMBER; v_act NUMBER; BEGIN
        v_c1 := f_cli('T_Upd_C1'); v_c2 := f_cli('T_Upd_C2'); v_p := f_pan(v_c1); COMMIT;
        UPDATE paniers SET id_client=v_c2 WHERE id_panier=v_p; COMMIT;
        SELECT id_client INTO v_act FROM paniers WHERE id_panier=v_p; ut.expect(v_act).to_equal(v_c2);
        DELETE FROM paniers WHERE id_panier=v_p; DELETE FROM clients WHERE id_client IN(v_c1,v_c2); COMMIT;
    END;
    PROCEDURE test_update_inexistant IS BEGIN pkg_paniers.update_one(p_id=>999999,p_id_client=>1); END;
    PROCEDURE test_delete_valide IS v_c NUMBER; v_p NUMBER; v_n NUMBER; BEGIN
        v_c := f_cli('T_Pan_Del'); v_p := f_pan(v_c); COMMIT;
        DELETE FROM paniers WHERE id_panier=v_p; COMMIT;
        SELECT COUNT(*) INTO v_n FROM paniers WHERE id_panier=v_p; ut.expect(v_n).to_equal(0);
        DELETE FROM clients WHERE id_client=v_c; COMMIT;
    END;
    PROCEDURE test_delete_inexistant IS BEGIN pkg_paniers.delete_one(p_id=>999999); END;
END test_pkg_paniers;
/

-- EXEC ut.run();
SELECT object_name, status FROM user_objects
WHERE object_name IN ('TEST_PKG_FABRICANTS','TEST_PKG_CLIENTS','TEST_PKG_PRODUITS','TEST_PKG_PANIERS')
ORDER BY object_name;
