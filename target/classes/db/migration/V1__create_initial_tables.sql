-- =========================================================
-- V1: Create Initial Tables for UFPMS
-- =========================================================

-- Table: faculties (Khoa)
CREATE TABLE faculties (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    code        VARCHAR(50)  NOT NULL UNIQUE,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: departments (Bộ môn / Đơn vị)
CREATE TABLE departments (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    code        VARCHAR(50)  NOT NULL UNIQUE,
    faculty_id  BIGINT       NOT NULL,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_dept_faculty FOREIGN KEY (faculty_id) REFERENCES faculties (id)
);

-- Table: users (Người dùng)
CREATE TABLE users (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(100) NOT NULL UNIQUE,
    email           VARCHAR(255) NOT NULL UNIQUE,
    password        VARCHAR(255) NOT NULL,
    full_name       VARCHAR(255) NOT NULL,
    faculty_id      BIGINT       NULL,
    department_id   BIGINT       NULL,
    role            ENUM('RESEARCHER', 'FACULTY_REVIEWER', 'UNIVERSITY_REVIEWER', 'ADMIN') NOT NULL DEFAULT 'RESEARCHER',
    enabled         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_faculty    FOREIGN KEY (faculty_id)    REFERENCES faculties    (id) ON DELETE SET NULL,
    CONSTRAINT fk_user_department FOREIGN KEY (department_id) REFERENCES departments  (id) ON DELETE SET NULL,
    INDEX idx_username (username),
    INDEX idx_email    (email)
);

-- Table: publications (Bài báo / Công trình khoa học)
CREATE TABLE publications (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    title               VARCHAR(500) NOT NULL,
    publication_type    ENUM('JOURNAL', 'CONFERENCE', 'BOOK_CHAPTER', 'OTHER') NOT NULL,
    journal_name        VARCHAR(255) NULL,
    conference_name     VARCHAR(255) NULL,
    year                INT          NOT NULL,
    volume              VARCHAR(50)  NULL,
    issue               VARCHAR(50)  NULL,
    pages               VARCHAR(50)  NULL,
    doi                 VARCHAR(255) NULL,
    abstract_text       TEXT         NULL,
    keywords            TEXT         NULL,
    pdf_filename        VARCHAR(255) NULL,
    pdf_path            VARCHAR(500) NULL,
    status              ENUM('DRAFT', 'SUBMITTED', 'FACULTY_REVIEWING', 'FACULTY_APPROVED', 'UNIVERSITY_REVIEWING', 'PUBLISHED', 'REJECTED')
                        NOT NULL DEFAULT 'DRAFT',
    created_by          BIGINT       NOT NULL,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    submitted_at        DATETIME     NULL,
    published_at        DATETIME     NULL,
    CONSTRAINT fk_pub_created_by FOREIGN KEY (created_by) REFERENCES users (id),
    INDEX idx_pub_status     (status),
    INDEX idx_pub_created_by (created_by),
    INDEX idx_pub_year       (year)
);

-- Table: publication_authors (Đồng tác giả)
CREATE TABLE publication_authors (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    publication_id      BIGINT       NOT NULL,
    user_id             BIGINT       NULL,
    author_name         VARCHAR(255) NOT NULL,
    author_email        VARCHAR(255) NULL,
    is_corresponding    BOOLEAN      NOT NULL DEFAULT FALSE,
    author_order        INT          NOT NULL DEFAULT 1,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_author_publication FOREIGN KEY (publication_id) REFERENCES publications (id) ON DELETE CASCADE,
    CONSTRAINT fk_author_user        FOREIGN KEY (user_id)         REFERENCES users        (id) ON DELETE SET NULL,
    CONSTRAINT uq_pub_author_order   UNIQUE (publication_id, author_order)
);

-- =========================================================
-- Seed Data (development only)
-- =========================================================

-- Default admin user (password: admin123 - BCrypt hashed)
INSERT INTO faculties (name, code) VALUES
    ('Khoa Công nghệ Thông tin', 'CNTT'),
    ('Khoa Kinh tế', 'KT'),
    ('Khoa Điện - Điện tử', 'DDT');

INSERT INTO departments (name, code, faculty_id) VALUES
    ('Bộ môn Kỹ thuật Phần mềm', 'KTPM', 1),
    ('Bộ môn Hệ thống Thông tin', 'HTTT', 1),
    ('Bộ môn Mạng Máy tính', 'MMT', 1);

-- Default admin user (password: admin123)
INSERT INTO users (username, email, password, full_name, role, enabled) VALUES
    ('admin', 'admin@ufpms.edu.vn', '$2a$10$yFvxcE.YnQ75xdAoG4osH.KEfM3rwb8iwDS.BMO/54KS44lI/8bge2', 'Administrator', 'ADMIN', TRUE);
