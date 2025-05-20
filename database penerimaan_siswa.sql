-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 20, 2025 at 02:11 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `penerimaan_siswa`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertMahasiswa` (IN `p_Nama_Lengkap` VARCHAR(100), IN `p_Tempat_Lahir` VARCHAR(100), IN `p_NIK` INT(20), IN `p_NISN` INT(20), IN `p_Nama_Orang_Tua` VARCHAR(100), IN `p_ID_Sekolah` VARCHAR(10), IN `p_No_HP` INT(20), IN `p_Alamat` VARCHAR(100), IN `p_Jalur_Pendaftaran` VARCHAR(20), IN `p_ID_Jurusan` VARCHAR(10))   BEGIN
    DECLARE p_ID_Calon_Mahasiswa VARCHAR(20);
    SET p_ID_Calon_Mahasiswa = p_NISN;

    INSERT INTO Tabel_Calon_Mahasiswa (
        ID_Calon_Mahasiswa, ID_Sekolah, NIK, NISN, No_HP, Alamat, Orang_Tua, Jalur_Pendaftaran
    ) VALUES (
        p_ID_Calon_Mahasiswa, p_ID_Sekolah, p_NIK, p_NISN, p_No_HP, p_Alamat, p_Nama_Orang_Tua, p_Jalur_Pendaftaran
    );

    INSERT INTO Tabel_Nama_Siswa (ID_Calon_Mahasiswa, Nama_Siswa)
    VALUES (p_ID_Calon_Mahasiswa, p_Nama_Lengkap);

    INSERT INTO Tabel_Tempat_Lahir (ID_Calon_Mahasiswa, Tempat_Lahir)
    VALUES (p_ID_Calon_Mahasiswa, p_Tempat_Lahir);

    INSERT INTO Tabel_Jurusan_Siswa (ID_Calon_Mahasiswa, ID_Jurusan)
    VALUES (p_ID_Calon_Mahasiswa, p_ID_Jurusan);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `log_pendaftaran` (IN `id_siswa` VARCHAR(20))   BEGIN
    INSERT INTO log_pendaftaran (ID_Calon_Mahasiswa, waktu_registrasi)
    VALUES (id_siswa, NOW());
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `log_pendaftaran`
--

CREATE TABLE `log_pendaftaran` (
  `ID_Log` int(11) NOT NULL,
  `ID_Calon_Mahasiswa` varchar(20) DEFAULT NULL,
  `Waktu_Registrasi` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `log_pendaftaran`
--

INSERT INTO `log_pendaftaran` (`ID_Log`, `ID_Calon_Mahasiswa`, `Waktu_Registrasi`) VALUES
(10, '240512345 ', '2025-05-20 19:07:58'),
(11, '240523456  ', '2025-05-20 19:08:12'),
(12, '240534567 ', '2025-05-20 19:08:26'),
(13, '240545678', '2025-05-20 19:08:36'),
(14, '240556789', '2025-05-20 19:08:48');

-- --------------------------------------------------------

--
-- Table structure for table `tabel_calon_mahasiswa`
--

CREATE TABLE `tabel_calon_mahasiswa` (
  `ID_Calon_Mahasiswa` varchar(20) NOT NULL,
  `ID_Sekolah` varchar(10) NOT NULL,
  `NIK` varchar(20) DEFAULT NULL,
  `NISN` varchar(20) DEFAULT NULL,
  `No_HP` varchar(20) DEFAULT NULL,
  `Alamat` varchar(100) DEFAULT NULL,
  `Orang_Tua` varchar(100) DEFAULT NULL,
  `Jalur_Pendaftaran` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tabel_calon_mahasiswa`
--

INSERT INTO `tabel_calon_mahasiswa` (`ID_Calon_Mahasiswa`, `ID_Sekolah`, `NIK`, `NISN`, `No_HP`, `Alamat`, `Orang_Tua`, `Jalur_Pendaftaran`) VALUES
('240512345', 'S01', '52012345678910', '66123456', '08123456789', 'Kota Malang', 'Rahman', 'SNBP'),
('240523456', 'S02', '52023456789101', '66234567', '08234567890', 'Surabaya', 'Sabil', 'Mandiri'),
('240534567', 'S03', '52034567891011', '66345678', '08345678910', 'Sulawesi', 'Andi', 'SNBT'),
('240545678', 'S04', '52045678910111', '66456789', '08456789101', 'Kalimantan', 'Bejo', 'SNBP'),
('240556789', 'S05', '52056789101112', '66567891', '08567891011', 'Jogja', 'Sahril', 'Mandiri');

--
-- Triggers `tabel_calon_mahasiswa`
--
DELIMITER $$
CREATE TRIGGER `Cek_Duplikasi_NIK_NISN` BEFORE INSERT ON `tabel_calon_mahasiswa` FOR EACH ROW BEGIN
    -- Cek NIK
    IF EXISTS (
        SELECT 1 FROM Tabel_Calon_Mahasiswa WHERE NIK = NEW.NIK
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Gagal: NIK sudah terdaftar';
    END IF;

    -- Cek NISN
    IF EXISTS (
        SELECT 1 FROM Tabel_Calon_Mahasiswa WHERE NISN = NEW.NISN
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Gagal: NISN sudah terdaftar';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Cek_Duplikasi_Update_NIK_NISN` BEFORE UPDATE ON `tabel_calon_mahasiswa` FOR EACH ROW BEGIN
    -- Cek NIK, tapi abaikan dirinya sendiri
    IF EXISTS (
        SELECT 1 FROM Tabel_Calon_Mahasiswa 
        WHERE NIK = NEW.NIK AND ID_Calon_Mahasiswa != OLD.ID_Calon_Mahasiswa
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'NIK sudah terdaftar oleh calon lain';
    END IF;

    -- Cek NISN, tapi abaikan dirinya sendiri
    IF EXISTS (
        SELECT 1 FROM Tabel_Calon_Mahasiswa 
        WHERE NISN = NEW.NISN AND ID_Calon_Mahasiswa != OLD.ID_Calon_Mahasiswa
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'NISN sudah terdaftar oleh calon lain';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tabel_jurusan`
--

CREATE TABLE `tabel_jurusan` (
  `ID_Jurusan` varchar(10) NOT NULL,
  `Nama_Jurusan` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tabel_jurusan`
--

INSERT INTO `tabel_jurusan` (`ID_Jurusan`, `Nama_Jurusan`) VALUES
('JUR01', 'Teknik Informatika'),
('JUR02', 'Tata Boga'),
('JUR03', 'Teknik Sipil'),
('JUR04', 'Teknik Mesin'),
('JUR05', 'Tata Busana');

-- --------------------------------------------------------

--
-- Table structure for table `tabel_jurusan_siswa`
--

CREATE TABLE `tabel_jurusan_siswa` (
  `ID_Calon_Mahasiswa` varchar(20) NOT NULL,
  `ID_Jurusan` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tabel_jurusan_siswa`
--

INSERT INTO `tabel_jurusan_siswa` (`ID_Calon_Mahasiswa`, `ID_Jurusan`) VALUES
('240512345', 'JUR01'),
('240523456', 'JUR02'),
('240534567', 'JUR03'),
('240545678', 'JUR04'),
('240556789', 'JUR05');

-- --------------------------------------------------------

--
-- Table structure for table `tabel_lokasi_sekolah`
--

CREATE TABLE `tabel_lokasi_sekolah` (
  `ID_Sekolah` varchar(10) NOT NULL,
  `Kota` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tabel_lokasi_sekolah`
--

INSERT INTO `tabel_lokasi_sekolah` (`ID_Sekolah`, `Kota`) VALUES
('S01', 'Malang'),
('S02', 'Surabaya'),
('S03', 'Sulawesi'),
('S04', 'Kalimantan'),
('S05', 'Jogja');

-- --------------------------------------------------------

--
-- Table structure for table `tabel_nama_siswa`
--

CREATE TABLE `tabel_nama_siswa` (
  `ID_Calon_Mahasiswa` varchar(20) NOT NULL,
  `Nama_Siswa` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tabel_nama_siswa`
--

INSERT INTO `tabel_nama_siswa` (`ID_Calon_Mahasiswa`, `Nama_Siswa`) VALUES
('240512345', 'Teguh Wijaya'),
('240523456', 'Adinda Fitrdina'),
('240534567', 'Ahmad Fikri'),
('240545678', 'Dodi Ropiki'),
('240556789', 'Ayunda Bilqis');

-- --------------------------------------------------------

--
-- Table structure for table `tabel_sekolah`
--

CREATE TABLE `tabel_sekolah` (
  `ID_Sekolah` varchar(10) NOT NULL,
  `Nama_Sekolah` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tabel_sekolah`
--

INSERT INTO `tabel_sekolah` (`ID_Sekolah`, `Nama_Sekolah`) VALUES
('S01', 'SMK 3 Malang'),
('S02', 'SMA 2 Surabaya'),
('S03', 'MAN 1 Sulawesi'),
('S04', 'SMK 1 Kalimantan'),
('S05', 'MA 3 Jogja');

-- --------------------------------------------------------

--
-- Table structure for table `tabel_tempat_lahir`
--

CREATE TABLE `tabel_tempat_lahir` (
  `ID_Calon_Mahasiswa` varchar(20) NOT NULL,
  `Tempat_Lahir` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tabel_tempat_lahir`
--

INSERT INTO `tabel_tempat_lahir` (`ID_Calon_Mahasiswa`, `Tempat_Lahir`) VALUES
('240512345', 'Kota Malang'),
('240523456', 'Surabaya'),
('240534567', 'Sulawesi'),
('240545678', 'Kalimantan'),
('240556789', 'Jogja');

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_data_siswa_lengkap`
-- (See below for the actual view)
--
CREATE TABLE `view_data_siswa_lengkap` (
`ID_Calon_Mahasiswa` varchar(20)
,`Nama_siswa` varchar(100)
,`Tempat_Lahir` varchar(100)
,`NIK` varchar(20)
,`NISN` varchar(20)
,`Orang_Tua` varchar(100)
,`Nama_Sekolah` varchar(100)
,`No_HP` varchar(20)
,`Alamat` varchar(100)
,`Jalur_Pendaftaran` varchar(20)
,`Nama_Jurusan` varchar(100)
);

-- --------------------------------------------------------

--
-- Structure for view `view_data_siswa_lengkap`
--
DROP TABLE IF EXISTS `view_data_siswa_lengkap`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_data_siswa_lengkap`  AS SELECT `tcm`.`ID_Calon_Mahasiswa` AS `ID_Calon_Mahasiswa`, `tns`.`Nama_Siswa` AS `Nama_siswa`, `ttl`.`Tempat_Lahir` AS `Tempat_Lahir`, `tcm`.`NIK` AS `NIK`, `tcm`.`NISN` AS `NISN`, `tcm`.`Orang_Tua` AS `Orang_Tua`, `ts`.`Nama_Sekolah` AS `Nama_Sekolah`, `tcm`.`No_HP` AS `No_HP`, `tcm`.`Alamat` AS `Alamat`, `tcm`.`Jalur_Pendaftaran` AS `Jalur_Pendaftaran`, `tj`.`Nama_Jurusan` AS `Nama_Jurusan` FROM (((((`tabel_calon_mahasiswa` `tcm` join `tabel_nama_siswa` `tns` on(`tcm`.`ID_Calon_Mahasiswa` = `tns`.`ID_Calon_Mahasiswa`)) join `tabel_tempat_lahir` `ttl` on(`tcm`.`ID_Calon_Mahasiswa` = `ttl`.`ID_Calon_Mahasiswa`)) join `tabel_sekolah` `ts` on(`tcm`.`ID_Sekolah` = `ts`.`ID_Sekolah`)) join `tabel_jurusan_siswa` `tjs` on(`tcm`.`ID_Calon_Mahasiswa` = `tjs`.`ID_Calon_Mahasiswa`)) join `tabel_jurusan` `tj` on(`tjs`.`ID_Jurusan` = `tj`.`ID_Jurusan`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `log_pendaftaran`
--
ALTER TABLE `log_pendaftaran`
  ADD PRIMARY KEY (`ID_Log`);

--
-- Indexes for table `tabel_calon_mahasiswa`
--
ALTER TABLE `tabel_calon_mahasiswa`
  ADD PRIMARY KEY (`ID_Calon_Mahasiswa`);

--
-- Indexes for table `tabel_jurusan`
--
ALTER TABLE `tabel_jurusan`
  ADD PRIMARY KEY (`ID_Jurusan`);

--
-- Indexes for table `tabel_jurusan_siswa`
--
ALTER TABLE `tabel_jurusan_siswa`
  ADD PRIMARY KEY (`ID_Calon_Mahasiswa`);

--
-- Indexes for table `tabel_lokasi_sekolah`
--
ALTER TABLE `tabel_lokasi_sekolah`
  ADD PRIMARY KEY (`ID_Sekolah`);

--
-- Indexes for table `tabel_nama_siswa`
--
ALTER TABLE `tabel_nama_siswa`
  ADD PRIMARY KEY (`ID_Calon_Mahasiswa`);

--
-- Indexes for table `tabel_sekolah`
--
ALTER TABLE `tabel_sekolah`
  ADD PRIMARY KEY (`ID_Sekolah`);

--
-- Indexes for table `tabel_tempat_lahir`
--
ALTER TABLE `tabel_tempat_lahir`
  ADD PRIMARY KEY (`ID_Calon_Mahasiswa`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `log_pendaftaran`
--
ALTER TABLE `log_pendaftaran`
  MODIFY `ID_Log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `tabel_jurusan_siswa`
--
ALTER TABLE `tabel_jurusan_siswa`
  ADD CONSTRAINT `tabel_jurusan_siswa_ibfk_1` FOREIGN KEY (`ID_Jurusan`) REFERENCES `tabel_jurusan` (`ID_Jurusan`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
