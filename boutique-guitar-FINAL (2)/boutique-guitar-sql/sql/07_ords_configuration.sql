-- Boutique de Guitare — Configuration ORDS
BEGIN
    FOR m IN (SELECT module_name FROM user_ords_modules WHERE module_name LIKE 'boutique.%')
    LOOP ORDS.DELETE_MODULE(p_module_name => m.module_name); END LOOP;
    COMMIT;
END;
/

-- ── FABRICANTS ───────────────────────────────────────────────
BEGIN
    ORDS.DEFINE_MODULE(p_module_name=>'boutique.fabricants',p_base_path=>'/fabricants/',p_status=>'PUBLISHED');
    ORDS.DEFINE_TEMPLATE(p_module_name=>'boutique.fabricants',p_pattern=>'.');
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.fabricants',p_pattern=>'.',p_method=>'GET',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_source=>'BEGIN pkg_fabricants.get_all; END;',p_items_per_page=>0);
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.fabricants',p_pattern=>'.',p_method=>'POST',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_items_per_page=>0,
        p_source=>'BEGIN pkg_fabricants.create_one(p_nom=>:nom_manu,p_tel=>:telephone); END;');
    ORDS.DEFINE_TEMPLATE(p_module_name=>'boutique.fabricants',p_pattern=>':id');
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.fabricants',p_pattern=>':id',p_method=>'GET',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_source=>'BEGIN pkg_fabricants.get_by_id(p_id=>:id); END;',p_items_per_page=>0);
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.fabricants',p_pattern=>':id',p_method=>'PUT',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_items_per_page=>0,
        p_source=>'BEGIN pkg_fabricants.update_one(p_id=>:id,p_nom=>:nom_manu,p_tel=>:telephone); END;');
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.fabricants',p_pattern=>':id',p_method=>'DELETE',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_source=>'BEGIN pkg_fabricants.delete_one(p_id=>:id); END;',p_items_per_page=>0);
    COMMIT;
END;
/

-- ── CLIENTS ──────────────────────────────────────────────────
BEGIN
    ORDS.DEFINE_MODULE(p_module_name=>'boutique.clients',p_base_path=>'/clients/',p_status=>'PUBLISHED');
    ORDS.DEFINE_TEMPLATE(p_module_name=>'boutique.clients',p_pattern=>'.');
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.clients',p_pattern=>'.',p_method=>'GET',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_source=>'BEGIN pkg_clients.get_all; END;',p_items_per_page=>0);
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.clients',p_pattern=>'.',p_method=>'POST',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_items_per_page=>0,
        p_source=>'BEGIN pkg_clients.create_one(p_nom=>:nom_client,p_tel=>:telephone,p_address=>:address); END;');
    ORDS.DEFINE_TEMPLATE(p_module_name=>'boutique.clients',p_pattern=>':id');
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.clients',p_pattern=>':id',p_method=>'GET',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_source=>'BEGIN pkg_clients.get_by_id(p_id=>:id); END;',p_items_per_page=>0);
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.clients',p_pattern=>':id',p_method=>'PUT',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_items_per_page=>0,
        p_source=>'BEGIN pkg_clients.update_one(p_id=>:id,p_nom=>:nom_client,p_tel=>:telephone,p_address=>:address); END;');
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.clients',p_pattern=>':id',p_method=>'DELETE',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_source=>'BEGIN pkg_clients.delete_one(p_id=>:id); END;',p_items_per_page=>0);
    COMMIT;
END;
/

-- ── PRODUITS ─────────────────────────────────────────────────
BEGIN
    ORDS.DEFINE_MODULE(p_module_name=>'boutique.produits',p_base_path=>'/produits/',p_status=>'PUBLISHED');
    ORDS.DEFINE_TEMPLATE(p_module_name=>'boutique.produits',p_pattern=>'.');
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.produits',p_pattern=>'.',p_method=>'GET',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_source=>'BEGIN pkg_produits.get_all; END;',p_items_per_page=>0);
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.produits',p_pattern=>'.',p_method=>'POST',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_items_per_page=>0,
        p_source=>'BEGIN pkg_produits.create_one(p_nom=>:nom_produit,p_prix=>:prix_produit,p_id_manu=>:id_manu); END;');
    ORDS.DEFINE_TEMPLATE(p_module_name=>'boutique.produits',p_pattern=>':id');
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.produits',p_pattern=>':id',p_method=>'GET',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_source=>'BEGIN pkg_produits.get_by_id(p_id=>:id); END;',p_items_per_page=>0);
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.produits',p_pattern=>':id',p_method=>'PUT',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_items_per_page=>0,
        p_source=>'BEGIN pkg_produits.update_one(p_id=>:id,p_nom=>:nom_produit,p_prix=>:prix_produit,p_id_manu=>:id_manu); END;');
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.produits',p_pattern=>':id',p_method=>'DELETE',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_source=>'BEGIN pkg_produits.delete_one(p_id=>:id); END;',p_items_per_page=>0);
    ORDS.DEFINE_TEMPLATE(p_module_name=>'boutique.produits',p_pattern=>'fabricant/:id_manu');
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.produits',p_pattern=>'fabricant/:id_manu',p_method=>'GET',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_source=>'BEGIN pkg_produits.get_by_fabricant(p_id_manu=>:id_manu); END;',p_items_per_page=>0);
    COMMIT;
END;
/

-- ── PANIERS ──────────────────────────────────────────────────
BEGIN
    ORDS.DEFINE_MODULE(p_module_name=>'boutique.paniers',p_base_path=>'/paniers/',p_status=>'PUBLISHED');
    ORDS.DEFINE_TEMPLATE(p_module_name=>'boutique.paniers',p_pattern=>'.');
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.paniers',p_pattern=>'.',p_method=>'GET',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_source=>'BEGIN pkg_paniers.get_all; END;',p_items_per_page=>0);
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.paniers',p_pattern=>'.',p_method=>'POST',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_items_per_page=>0,
        p_source=>'BEGIN pkg_paniers.create_one(p_id_client=>:id_client,p_date=>TO_DATE(:date_creation,''YYYY-MM-DD'')); END;');
    ORDS.DEFINE_TEMPLATE(p_module_name=>'boutique.paniers',p_pattern=>':id');
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.paniers',p_pattern=>':id',p_method=>'GET',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_source=>'BEGIN pkg_paniers.get_by_id(p_id=>:id); END;',p_items_per_page=>0);
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.paniers',p_pattern=>':id',p_method=>'PUT',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_items_per_page=>0,
        p_source=>'BEGIN pkg_paniers.update_one(p_id=>:id,p_id_client=>:id_client,p_date=>TO_DATE(:date_creation,''YYYY-MM-DD'')); END;');
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.paniers',p_pattern=>':id',p_method=>'DELETE',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_source=>'BEGIN pkg_paniers.delete_one(p_id=>:id); END;',p_items_per_page=>0);
    ORDS.DEFINE_TEMPLATE(p_module_name=>'boutique.paniers',p_pattern=>'client/:id_client');
    ORDS.DEFINE_HANDLER(p_module_name=>'boutique.paniers',p_pattern=>'client/:id_client',p_method=>'GET',
        p_source_type=>ORDS.SOURCE_TYPE_PLSQL,p_source=>'BEGIN pkg_paniers.get_by_client(p_id_client=>:id_client); END;',p_items_per_page=>0);
    COMMIT;
END;
/

SELECT module_name, base_path, status FROM user_ords_modules WHERE module_name LIKE 'boutique.%' ORDER BY 1;
