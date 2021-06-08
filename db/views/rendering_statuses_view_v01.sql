SELECT
  *,
  CASE WHEN unsafemode_status IS NULL THEN
    CASE safemode_status
      WHEN 0 THEN 0     --- SAFEMODE_OK
      WHEN 1 THEN 2     --- SAFEMODE_WARN
      WHEN 2 THEN 4     --- SAFEMODE_ERROR
    ELSE
      NULL
    END
  ELSE
    CASE
      WHEN unsafemode_status = 2  THEN 5   --- UNSAFEMODE_ERROR
      WHEN safemode_status = 2    THEN 4   --- SAFEMODE_ERROR
      WHEN unsafemode_status = 1  THEN 3   --- UNSAFEMODE_WARN
      WHEN safemode_status = 1    THEN 2   --- SAFEMODE_WARN
      WHEN safemode_status = 0    THEN 0   --- SAFEMODE_OK
      WHEN unsafemode_status = 0  THEN 1   --- UNSAFEMODE_OK
    ELSE
      NULL
    END
  END AS status
FROM (
  SELECT
    md5(host_id::text) AS id,
    host_id,
    max(safemode_status) AS safemode_status,
    -- ignore unsafemode_status when safemode_render is enabled
    CASE WHEN NOT EXISTS (SELECT 1 FROM settings WHERE name = 'safemode_render' AND value = '--- false') THEN
      NULL
    ELSE
      max(unsafemode_status)
    END AS unsafemode_status
  FROM
    rendering_status_combinations
  GROUP BY
    host_id
) t
