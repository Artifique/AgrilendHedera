import React from 'react';
import '../App.css';

const Home = () => {
  return (
    <div className="home-container">
      <header className="home-header">
        <h1>Bienvenue sur Agri-Lend</h1>
        <p>La plateforme de vente directe qui connecte agriculteurs et acheteurs en toute confiance.</p>
        <div className="home-buttons">
          <a href="#services" className="btn btn-primary">Découvrez nos solutions</a>
          <a href="#contact" className="btn btn-secondary">Contactez-nous</a>
        </div>
      </header>
    </div>
  );
};

export default Home;