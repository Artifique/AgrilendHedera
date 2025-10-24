import React from "react";

const Services = () => {
  return (
    <section id="services" className="services-section">
      <div className="container">
        <h2>Nos Solutions</h2>
        <p className="section-subtitle">
          Des outils conçus pour simplifier votre quotidien et maximiser votre
          rentabilité.
        </p>
        <div className="services-grid">
          <div className="service-card">
            <div className="service-icon">
              <i className="fas fa-store"></i>
            </div>
            <h3>Vente Directe Simplifiée</h3>
            <p>
              Une plateforme intuitive pour que les agriculteurs vendent leurs
              produits directement aux acheteurs, sans intermédiaire.
            </p>
          </div>
          <div className="service-card">
            <div className="service-icon">
              <i className="fas fa-shield-alt"></i>
            </div>
            <h3>Engagement et transparence</h3>
            <p>
              Nous établissons avec chaque producteur un contrat clair qui
              définit les attentes, les normes de qualité et les responsabilités
              de chacun. Notre démarche repose sur la confiance et la
              transparence : chaque étape, de la sélection des produits à leur
              validation, est suivie et documentée pour garantir une relation
              durable et équitable entre toutes les parties.
            </p>
          </div>
          <div className="service-card">
            <div className="service-icon">
              <i className="fas fa-truck"></i>
            </div>
            <h3>Paiement sécurisé et flexible</h3>
            <p>
              Les producteurs reçoivent leur argent rapidement, de manière
              sécurisée, soit en monnaie locale soit via un paiement numérique,
              selon leur préférence..
            </p>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Services;
