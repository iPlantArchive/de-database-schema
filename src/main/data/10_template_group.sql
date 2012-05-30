INSERT INTO template_group (id, name, description, workspace_id)
       VALUES ('g12c7a585ec233352e31302e323112a7ccf18bfd7364',
               'Public Applications', '', 0);

INSERT INTO template_group (id, name, description, workspace_id)
       VALUES ('g5401bd146c144470aedd57b47ea1b979',
               'Beta', '', 0);

INSERT INTO template_group_group (parent_group_id, subgroup_id, hid)
       SELECT parent.hid, child.hid, 0
       FROM template_group parent, template_group child
       WHERE parent.id = 'g12c7a585ec233352e31302e323112a7ccf18bfd7364'
       AND child.id = 'g5401bd146c144470aedd57b47ea1b979';
