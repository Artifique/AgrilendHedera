import React, { useState } from 'react';
import logo from '../logo.png';

const Navbar = () => {
  const [click, setClick] = useState(false);

  const handleClick = () => setClick(!click);
  const closeMobileMenu = () => setClick(false);

  return (
    <nav className="navbar">
      <div className="navbar-container">
        <a href="/" className="navbar-logo" onClick={closeMobileMenu}>
          <img src={logo} alt="Agri-Lend Logo" style={{ height: '50px' }} />
        </a>
        <div className="menu-icon" onClick={handleClick}>
          <i className={click ? 'fas fa-times' : 'fas fa-bars'} />
        </div>
        <ul className={click ? 'nav-menu active' : 'nav-menu'}>
          <li className="nav-item">
            <a href="#about" className="nav-links" onClick={closeMobileMenu}>
              À propos
            </a>
          </li>
          <li className="nav-item">
            <a href="#services" className="nav-links" onClick={closeMobileMenu}>
              Services
            </a>
          </li>
          <li className="nav-item">
            <a href="#testimonials" className="nav-links" onClick={closeMobileMenu}>
              Témoignages
            </a>
          </li>
          <li className="nav-item">
            <a href="#contact" className="nav-links" onClick={closeMobileMenu}>
              Contact
            </a>
          </li>
        </ul>
      </div>
    </nav>
  );
};

export default Navbar;