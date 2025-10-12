-- Make username column nullable so users can be created without a username
-- They will set it up during the profile setup flow

ALTER TABLE users ALTER COLUMN username DROP NOT NULL;
