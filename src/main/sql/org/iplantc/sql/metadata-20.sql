\set ON_ERROR_STOP ON

BEGIN;

-- Add a disabled column to the transformation activity table.
ALTER TABLE transformation_activity ADD COLUMN disabled BOOLEAN;
ALTER TABLE transformation_activity ALTER COLUMN disabled SET DEFAULT FALSE;
UPDATE transformation_activity SET disabled = FALSE;
ALTER TABLE transformation_activity ALTER COLUMN disabled SET NOT NULL;

-- Drop and re-create the analysis listing view, including the deleted and disabled flags.  The restriction that this
-- view only displays analyses that haven't been marked as deleted has also been removed.
DROP VIEW analysis_listing;
CREATE VIEW analysis_listing AS
    SELECT analysis.hid,
           analysis.id,
           analysis."name",
           analysis.description,
           integration.integrator_name,
           integration.integrator_email,
           analysis.integration_date,
           analysis.wikiurl,
           CAST(COALESCE(AVG(ratings.rating), 0.0) AS DOUBLE PRECISION) AS average_rating,
           EXISTS (
               SELECT *
               FROM template_group_template tgt
               JOIN template_group tg ON tgt.template_group_id = tg.hid
               JOIN workspace w ON tg.workspace_id = w.id
               WHERE analysis.hid = tgt.template_id
               AND w.is_public IS TRUE
           ) AS is_public, (
               SELECT COUNT(*)
               FROM transformation_task_steps tts
               WHERE tts.transformation_task_id = analysis.hid
           ) AS step_count,
           analysis.deleted,
           analysis.disabled
    FROM transformation_activity analysis
         LEFT JOIN integration_data integration ON analysis.integration_data_id = integration.id
         LEFT JOIN ratings ON analysis.hid = ratings.transformation_activity_id
    GROUP BY analysis.hid,
             analysis.id,
             analysis."name",
             analysis.description,
             integration.integrator_name,
             integration.integrator_email,
             analysis.integration_date,
             analysis.wikiurl,
             analysis.deleted,
             analysis.disabled;

COMMIT;