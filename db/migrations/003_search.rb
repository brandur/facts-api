Sequel.migration do
  up do
    # categories
    add_column :categories, :tsv, 'TSVector'
    run %{
CREATE INDEX categories_tsv_gin ON categories \
USING GIN(tsv);
}
    run %{
CREATE TRIGGER categories_ts_tsv \
BEFORE INSERT OR UPDATE ON categories \
FOR EACH ROW EXECUTE PROCEDURE \
tsvector_update_trigger(tsv, 'pg_catalog.english', name);
}
    run %{
UPDATE categories SET tsv=to_tsvector(name);
}

    # facts
    add_column :facts, :tsv, 'TSVector'
    run %{
CREATE INDEX facts_tsv_gin ON facts \
USING GIN(tsv);
}
    run %{
CREATE TRIGGER facts_ts_tsv \
BEFORE INSERT OR UPDATE ON facts \
FOR EACH ROW EXECUTE PROCEDURE \
tsvector_update_trigger(tsv, 'pg_catalog.english', content);
}
    run %{
UPDATE facts SET tsv=to_tsvector(content);
}
  end

  down do
    # categories
    run %{DROP TRIGGER categories_ts_tsv ON categories;}
    run %{DROP INDEX categories_tsv_gin;}
    drop_column  :categories, :tsv

    # facts
    run %{DROP TRIGGER facts_ts_tsv ON facts;}
    run %{DROP INDEX facts_tsv_gin;}
    drop_column  :facts, :tsv
  end
end
